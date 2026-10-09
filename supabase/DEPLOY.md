# SawaLove deployment (blue-green on Supabase)

The stack is **Flutter app + Supabase** (Postgres, Auth, Storage, Edge
Functions). Blue-green here means: *never break the currently-installed app
while shipping new backend behavior.*

## Principles

1. **Migrations are additive-first.** New columns/tables/RPCs are added in
   one release; old columns/tables/RPCs are only dropped in a later release
   after the app version that stopped using them is fully rolled out
   (Play Store staged rollout complete).
2. **Two "colors" = two app generations.**
   - **Blue** = app builds currently in production (old RPC contracts).
   - **Green** = new build staged on the internal testing track.
   The database must serve both simultaneously during rollout. That is why
   every RPC is versioned (`fetch_matches_v1`, `fetch_matches_v2`) when the
   signature or result shape changes instead of editing in place.
3. **Edge Functions are deployed per-function with activation only after a
   smoke test.** The old function version keeps serving until the new one is
   verified (see `scripts/deploy_supabase.ps1`).
4. **Database branching for risky changes.** For schema changes that cannot
   be additive (rare), use a Supabase branch to test against a copy:

   ```bash
   supabase branches create green-<ticket>
   # apply migrations, run smoke tests against the branch URL
   supabase branches delete green-<ticket>   # after merge+promote
   ```

## Release flow

```powershell
# 1. Ship additive migrations + new *_v2 RPCs + edge functions
.\scripts\deploy_supabase.ps1 -Migrations -Functions

# 2. Build the green AAB (points at the same project; new defines in .env.release)
.\scripts\build_release_aab.ps1

# 3. Internal testing track → verify → staged production rollout
# 4. After rollout is complete (>= 2 weeks or 100%):
#    drop deprecated RPCs/columns with a follow-up migration
.\scripts\deploy_supabase.ps1 -Migrations
```

## Rollback

- **App:** halt the staged rollout in Play Console; the blue build keeps
  working because additive migrations never removed what it needs.
- **Edge Functions:** redeploy the previous function bundle from git
  (`scripts/deploy_supabase.ps1 -FunctionsOnly -Ref <previous-tag>`).
- **Schema:** never "roll back" destructive changes forward-fixed; the
  additive-first rule makes schema rollbacks almost never necessary.

## Health & alerts

- Postgres + Auth + Storage health: Supabase Dashboard → Reports.
- App-level health: `public.app_logs` + `public.alerts` (see
  `supabase/migrations/20261009040000_alerts.sql`). Wire Logs → Alerts
  webhooks for email/Slack delivery.
- The Flutter app surfaces a degraded mode automatically when the Supabase
  URL is unreachable (demo-safe fallbacks are compiled in for debug builds).
