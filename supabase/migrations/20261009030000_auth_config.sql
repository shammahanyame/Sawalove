-- Auth hardening (config-as-code where Postgres allows).
--
-- DASHBOARD SETTINGS (Project Settings → Authentication) — required, not
-- expressible in SQL migrations:
--   • Password reset links expire: set "Password reset / recovery link
--     expiry" to 3600 seconds (1 hour).
--   • Enable "leaked password protection" (HaveIBeenPwned check).
--   • Confirm email = ON; OTP expiry 10 min.
--   • Auth rate limits (Auth settings → Advanced):
--       - token refresh: 150 / 5 min / IP
--       - sign in / sign up: 30 / 5 min / IP
--       - password recovery: 2 / hour / IP  ← password-reset flood protection
--       - magic link / OTP: 5 / hour / IP
--   • URL Configuration → Additional redirect URLs:
--       io.sawalove.app://login-callback
--
-- The SQL below adds what CAN live in migrations.

-- 1. Guarantee a users row exists for every new auth user (password, phone,
--    or OAuth signup all land here via the GoTrue trigger).
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, phone, email, name, country, visible)
  values (
    new.id,
    new.phone,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce(new.raw_user_meta_data->>'country', ''),
    false
  )
  on conflict (id) do update set
    phone = coalesce(excluded.phone, public.users.phone),
    email = coalesce(excluded.email, public.users.email),
    name = coalesce(nullif(excluded.name, ''), public.users.name),
    country = coalesce(nullif(excluded.country, ''), public.users.country),
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_auth_user();

-- 2. Password reset audit: GoTrue handles the reset links themselves (expiry
--    and flood limits are dashboard settings above). For app-level visibility
--    the Flutter client calls log_event('warn', 'password_reset_requested')
--    when the user taps "Forgot password"; alerts.sql watches that event.

-- 3. Alerting: security events land in app_logs; the alerts migration creates
--    pg_cron jobs that detect spikes.
