# SawaLove Backend

The Flutter app talks to **Supabase** directly (Postgres + Auth + Storage +
Edge Functions). There is no separate PHP/Node server anymore — the previous
`backend/php` API was fully migrated into SQL migrations and Edge Functions in
`supabase/`.

## One-time setup

1. Create a project at [supabase.com](https://supabase.com) (or use an
   existing one). Note the **project ref** and **anon key** from
   Project Settings → API.
2. Install the CLI and link:

   ```bash
   npm i -g supabase
   supabase login
   cd supabase && supabase link --project-ref <your-project-ref>
   ```

3. Apply the migrations **in order**:

   ```bash
   supabase db push
   ```

   Files applied: initial schema → RLS hardening → full backend schema →
   full RLS → RPCs → auth config → alerts (pg_cron).

4. Optional test data: `supabase/seed/visible_profiles.sql`.
5. Deploy the Edge Functions:

   ```bash
   supabase functions deploy ai-icebreakers
   supabase functions deploy ai-bio-suggestions
   ```

   Then set their secrets:

   ```bash
   supabase secrets set OPENAI_API_KEY=sk-... ALLOWED_ORIGINS=https://sawalove.com
   ```

   AI spend caps are configurable: `AI_GLOBAL_DAILY_CAP_CENTS` (default 500)
   and `AI_USER_DAILY_CAP_CENTS` (default 25).

6. Auth dashboard settings (one-time, see
   `supabase/migrations/20261009030000_auth_config.sql` header for the full
   list): enable the email/phone/Google/Apple providers you want, set the
   password reset link expiry to 1 hour, enable leaked-password protection,
   and configure the auth rate limits (recovery: 2/hour/IP).
7. In Authentication → URL Configuration add
   `io.sawalove.app://login-callback` to Additional Redirect URLs.

## Security model

| Layer | Where |
| --- | --- |
| Row Level Security | `supabase/migrations/20261009010000_rls_full.sql` |
| Authorization (RPC + RLS checks) | `supabase/migrations/20261009020000_rpcs.sql` |
| Input validation (types, lengths, enums) | CHECK constraints + RPC guards |
| Rate limiting | `rate_limits` table + `rate_limit_take()` in every write RPC |
| Password reset expiry | Dashboard setting (1 h) + flood limit 2/hour/IP |
| CORS | Edge Functions (`ALLOWED_ORIGINS` secret) |
| Error handling | RPC error codes mapped in `authErrorMessage()` |
| Indexes | Every foreign key + query path in the schema migration |
| Logging | `app_logs` table, written by RPCs/Edge Functions |
| Alerts | `alerts.sql` pg_cron jobs → `public.alerts` (hook a webhook in Logs → Alerts) |

## Blue-green deployment

See `supabase/DEPLOY.md`. Migrations are additive-only; branches let you test
schema + function changes against production data before promotion.

## Flutter connection

The app reads these compile-time Dart defines (`.env.release` for release
builds, or `--dart-define` for debug):

```text
SUPABASE_URL
SUPABASE_ANON_KEY
SUPABASE_PROFILE_PHOTOS_BUCKET
SUPABASE_AUTH_REDIRECT_TO
SUPABASE_PHONE_AUTH_ENABLED
SUPABASE_EMAIL_AUTH_ENABLED
SUPABASE_GOOGLE_AUTH_ENABLED
SUPABASE_APPLE_AUTH_ENABLED
```

```powershell
.\scripts\build_release_aab.ps1
```

Debug:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```
