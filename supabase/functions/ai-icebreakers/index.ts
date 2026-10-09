// SawaLove AI gateway — ice-breaker suggestions.
// Port of the PHP /ai/icebreakers endpoint: daily spend caps enforced against
// the ai_usage ledger BEFORE any model call, input validation, structured
// logging, CORS.
import { createClient } from 'jsr:@supabase/supabase-js@2';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': Deno.env.get('ALLOWED_ORIGINS') ?? 'https://sawalove.com',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// Daily caps (US cents): global hard ceiling + per-user ceiling.
const GLOBAL_DAILY_CAP_CENTS = Number(Deno.env.get('AI_GLOBAL_DAILY_CAP_CENTS') ?? '500');
const USER_DAILY_CAP_CENTS = Number(Deno.env.get('AI_USER_DAILY_CAP_CENTS') ?? '25');
// Estimated cost per call, rounded up to whole cents.
const EST_COST_CENTS = 2;
const MODEL = 'gpt-4o-mini';

const SYSTEM_PROMPT = `You generate short, friendly ice-breaker questions for a
dating app for Cameroonians. Reply with ONLY a JSON array of 4-6 strings, each
under 120 characters, warm and specific. No numbering, no markdown.`;

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

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // ── Auth: verify the caller's JWT and resolve their uid ────────────────
    const authHeader = req.headers.get('Authorization') ?? '';
    const token = authHeader.replace(/^Bearer\s+/i, '');
    if (!token) return fail('not_authenticated', 'Sign in first.', 401);

    const { data: userData, error: userError } = await supabase.auth.getUser(token);
    if (userError || !userData.user) return fail('not_authenticated', 'Sign in first.', 401);
    const uid = userData.user.id;

    // ── Input validation ───────────────────────────────────────────────────
    let body: unknown;
    try { body = await req.json(); } catch { return fail('invalid_json', 'Body must be JSON.', 400); }
    const about = typeof (body as { about?: unknown })?.about === 'string'
      ? (body as { about: string }).about.trim().slice(0, 500)
      : '';

    // ── Spend-cap check (hard limit, ledger-backed) ────────────────────────
    const today = new Date().toISOString().slice(0, 10);
    const { data: spend, error: spendError } = await supabase
      .from('ai_usage')
      .select('cost_usd_cents, user_id')
      .eq('day', today);

    if (spendError) {
      console.error('ai_usage read failed', spendError.message);
      return fail('internal_error', 'Could not check AI budget.', 500);
    }

    const globalCents = spend.reduce((sum, row) => sum + row.cost_usd_cents, 0);
    const userCents = spend.filter((r) => r.user_id === uid)
      .reduce((sum, row) => sum + row.cost_usd_cents, 0);

    if (globalCents + EST_COST_CENTS > GLOBAL_DAILY_CAP_CENTS) {
      await supabase.from('app_logs').insert({
        level: 'warn', event: 'ai_budget_exhausted', user_id: uid,
        context: { endpoint: 'icebreakers', global_cents: globalCents },
      });
      return fail('budget_exhausted', 'AI suggestions are unavailable right now.', 429);
    }
    if (userCents + EST_COST_CENTS > USER_DAILY_CAP_CENTS) {
      return fail('user_budget_exhausted', 'You reached today\'s suggestion limit. Try again tomorrow.', 429);
    }

    // ── Model call ─────────────────────────────────────────────────────────
    const openAiKey = Deno.env.get('OPENAI_API_KEY');
    if (!openAiKey) return fail('ai_not_configured', 'AI is not configured.', 503);

    const completion = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openAiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: MODEL,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: about || 'Generate ice-breaker questions.' },
        ],
        max_tokens: 300,
        temperature: 0.9,
      }),
    });

    if (!completion.ok) {
      console.error('openai error', completion.status, await completion.text());
      return fail('provider_error', 'AI suggestions failed. Try again later.', 502);
    }

    const completionData = await completion.json();
    const raw = completionData?.choices?.[0]?.message?.content ?? '';

    // Parse + clamp: ≤6 items, ≤160 chars.
    let suggestions: string[] = [];
    try {
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed)) {
        suggestions = parsed
          .filter((s): s is string => typeof s === 'string')
          .map((s) => s.trim().slice(0, 160))
          .filter((s) => s.length > 0)
          .slice(0, 6);
      }
    } catch { /* fallthrough with empty list */ }

    if (suggestions.length === 0) return fail('provider_error', 'AI suggestions failed. Try again later.', 502);

    // ── Ledger + logging ───────────────────────────────────────────────────
    await supabase.from('ai_usage').insert({
      user_id: uid, endpoint: 'icebreakers', model: MODEL,
      cost_usd_cents: EST_COST_CENTS, day: today,
    });
    await supabase.from('app_logs').insert({
      level: 'info', event: 'ai_suggestions_served', user_id: uid,
      context: { endpoint: 'icebreakers', count: suggestions.length },
    });

    return json({ suggestions });
  } catch (err) {
    console.error('icebreakers unexpected error', err);
    return fail('internal_error', 'Unexpected error.', 500);
  }
});
