# Supabase Backend

This Flutter app uses Supabase directly from Dart. There is no separate Node,
Python, PHP, or Firebase backend in the current code.

## Create The Backend

1. Open your Supabase project.
2. Go to `SQL Editor`.
3. Run `supabase/migrations/20260602000000_initial_schema.sql`.
4. Optional for testing: run `supabase/seed/visible_profiles.sql` so discovery
   has visible profiles immediately.
5. In `Authentication > Providers`, enable the providers you want:
   - Phone: enable phone sign-in and configure an SMS provider. If this is
     off, Supabase returns `phone_provider_disabled` and the Flutter app will
     disable the phone login button after reading the auth settings endpoint.
   - Email: enable email/password sign-in for email signup and login.
   - Google and Apple: enable each OAuth provider you want to show in the app.
6. In `Authentication > URL Configuration`, add this redirect URL to
   `Additional Redirect URLs`:
   `io.sawalove.app://login-callback`

## Flutter Connection

The app reads these compile-time Dart defines:

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

`.env.release` already contains the values used by `scripts/build_release_aab.ps1`.
For local development, run Flutter with the same defines:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key `
  --dart-define=SUPABASE_PROFILE_PHOTOS_BUCKET=profile-photos `
  --dart-define=SUPABASE_AUTH_REDIRECT_TO=io.sawalove.app://login-callback
```

For release builds on this project, use:

```powershell
.\scripts\build_release_aab.ps1
```
