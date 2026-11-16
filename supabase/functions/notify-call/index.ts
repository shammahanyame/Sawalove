// SawaLove — incoming-call push sender.
//
// Rings the callee's devices through Firebase Cloud Messaging (HTTP v1) so a
// call arrives even when their app is backgrounded or closed. The caller
// invokes this right after `start_call`; the call row is the authorization,
// exactly like `agora-token`: only the caller of a still-ringing call can send
// the ring.
//
// Secrets: FCM_SERVICE_ACCOUNT (the Firebase service-account JSON, one line),
// optional FIREBASE_PROJECT_ID (defaults to the service account's project).
import { createClient } from 'jsr:@supabase/supabase-js@2';
import { JWT } from 'npm:google-auth-library@9';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': Deno.env.get('ALLOWED_ORIGINS') ?? 'https://sawalove.com',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// The caller's client gives up after ~30s; a ring that lands later is noise.
const RING_TTL_SECONDS = 45;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

function fail(code: string, message: string, status: number): Response {
  return json({ error: { code, message } }, status);
}

type ServiceAccount = {
  project_id?: string;
  client_email?: string;
  private_key?: string;
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS_HEADERS });
  if (req.method !== 'POST') return fail('method_not_allowed', 'POST only', 405);

  let serviceAccount: ServiceAccount;
  try {
    serviceAccount = JSON.parse(Deno.env.get('FCM_SERVICE_ACCOUNT') ?? 'null');
  } catch {
    serviceAccount = {};
  }
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID') ?? serviceAccount.project_id ?? '';
  if (!serviceAccount.client_email || !serviceAccount.private_key || !projectId) {
    console.error('FCM_SERVICE_ACCOUNT / FIREBASE_PROJECT_ID are not set');
    return fail('push_not_configured', 'Call notifications are not configured.', 503);
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const jwt = authHeader.replace(/^Bearer\s+/i, '');
  if (!jwt) return fail('not_authenticated', 'Sign in first.', 401);

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
  if (userError || !userData.user) {
    return fail('not_authenticated', 'Sign in first.', 401);
  }
  const uid = userData.user.id;

  let body: { call_id?: unknown };
  try {
    body = await req.json();
  } catch {
    return fail('invalid_json', 'Body must be JSON.', 400);
  }
  const callId = typeof body?.call_id === 'string' ? body.call_id : '';
  if (!/^[0-9a-f-]{36}$/i.test(callId)) {
    return fail('invalid_call_id', 'call_id must be a UUID.', 400);
  }

  const { data: call, error: callError } = await supabase
    .from('calls')
    .select('id, match_id, caller_id, callee_id, status')
    .eq('id', callId)
    .maybeSingle();

  if (callError) {
    console.error('calls read failed', callError.message);
    return fail('internal_error', 'Could not load the call.', 500);
  }
  if (!call) return fail('call_not_found', 'This call does not exist.', 404);
  if (call.caller_id !== uid) {
    return fail('not_the_caller', 'Only the caller can ring this call.', 403);
  }
  if (call.status !== 'ringing') {
    return fail('call_not_ringing', 'This call is no longer ringing.', 409);
  }

  const { data: caller } = await supabase
    .from('users')
    .select('name, photo, faith')
    .eq('id', uid)
    .maybeSingle();

  const { data: tokens, error: tokensError } = await supabase
    .from('push_tokens')
    .select('token')
    .eq('user_id', call.callee_id);

  if (tokensError) {
    console.error('push_tokens read failed', tokensError.message);
    return fail('internal_error', 'Could not load the callee devices.', 500);
  }
  if (!tokens || tokens.length === 0) {
    return json({ sent: 0, pruned: 0, failed: 0, reason: 'no_devices' });
  }

  const callerName = caller?.name?.toString() || 'Someone';
  const callerAvatar = caller?.photo?.toString() ?? '';

  const data: Record<string, string> = {
    type: 'incoming_call',
    callId: call.id,
    matchId: call.match_id,
    callerId: call.caller_id,
    callerName,
    callerAvatar,
  };
  if (caller?.faith) data.faith = caller.faith.toString();

  const authorization = await new JWT({
    email: serviceAccount.client_email,
    key: serviceAccount.private_key,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  }).authorize();

  const accessToken = authorization.access_token ?? '';
  if (!accessToken) {
    console.error('Could not mint a Firebase access token');
    return fail('push_auth_failed', 'Could not reach Firebase.', 502);
  }

  let sent = 0;
  let pruned = 0;
  let failed = 0;

  for (const row of tokens) {
    const token = row.token?.toString() ?? '';
    if (!token) continue;

    const message = {
      message: {
        token,
        notification: {
          title: `${callerName} is calling`,
          body: 'Tap to answer the video call.',
        },
        android: {
          priority: 'HIGH',
          ttl: `${RING_TTL_SECONDS}s`,
          notification: {
            channel_id: 'incoming_calls',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            sound: 'default',
            tag: `call-${call.id}`,
            visibility: 'PUBLIC',
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
            'apns-expiration': `${Math.floor(Date.now() / 1000) + RING_TTL_SECONDS}`,
          },
          payload: {
            aps: {
              alert: {
                title: `${callerName} is calling`,
                body: 'Tap to answer the video call.',
              },
              sound: 'default',
              'interruption-level': 'time-sensitive',
            },
          },
        },
        data,
      },
    };

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(message),
      },
    );

    if (response.ok) {
      sent += 1;
      continue;
    }

    failed += 1;
    const text = await response.text();
    // A dead token (app uninstalled, reinstalled) should not be retried
    // forever: the housekeeping job only prunes tokens by age.
    if (text.includes('UNREGISTERED') || text.includes('NOT_FOUND')) {
      const { error } = await supabase.from('push_tokens').delete().eq('token', token);
      if (!error) pruned += 1;
    } else {
      console.error('FCM send failed', response.status, text);
    }
  }

  return json({ sent, pruned, failed });
});
