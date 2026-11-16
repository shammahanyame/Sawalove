// SawaLove — Agora RTC token issuer.
//
// The App Certificate must never ship in the app, so the Flutter client asks
// this function for a short-lived channel token. Authorization is the call
// row itself: only the caller and callee of a live call can get a token for
// its channel, and the numeric Agora uid is derived from which side they are
// (1 = caller, 2 = callee), which keeps both clients stable across token
// renewals.
//
// Secrets: AGORA_APP_ID, AGORA_APP_CERTIFICATE (supabase secrets set ...).
import { createClient } from 'jsr:@supabase/supabase-js@2';
import { RtcTokenBuilder, RtcRole } from 'npm:agora-token@2.0.4';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': Deno.env.get('ALLOWED_ORIGINS') ?? 'https://sawalove.com',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const TOKEN_TTL_SECONDS = 3600;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

function fail(code: string, message: string, status: number): Response {
  return json({ error: { code, message } }, status);
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS_HEADERS });
  if (req.method !== 'POST') return fail('method_not_allowed', 'POST only', 405);

  const appId = Deno.env.get('AGORA_APP_ID') ?? '';
  const appCertificate = Deno.env.get('AGORA_APP_CERTIFICATE') ?? '';
  if (!appId || !appCertificate) {
    console.error('AGORA_APP_ID / AGORA_APP_CERTIFICATE are not set');
    return fail('calls_not_configured', 'Video calling is not configured.', 503);
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
    .select('id, channel_name, caller_id, callee_id, status')
    .eq('id', callId)
    .maybeSingle();

  if (callError) {
    console.error('calls read failed', callError.message);
    return fail('internal_error', 'Could not load the call.', 500);
  }
  if (!call) return fail('call_not_found', 'This call does not exist.', 404);
  if (call.caller_id !== uid && call.callee_id !== uid) {
    return fail('not_a_participant', 'You are not part of this call.', 403);
  }
  if (call.status !== 'ringing' && call.status !== 'active') {
    return fail('call_ended', 'This call has already ended.', 409);
  }

  const rtcUid = call.caller_id === uid ? 1 : 2;
  const expiresAt = Math.floor(Date.now() / 1000) + TOKEN_TTL_SECONDS;
  const token = RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    call.channel_name,
    rtcUid,
    RtcRole.PUBLISHER,
    expiresAt,
    expiresAt,
  );

  return json({
    app_id: appId,
    channel_name: call.channel_name,
    uid: rtcUid,
    token,
    expires_at: expiresAt,
  });
});
