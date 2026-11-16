# SawaLove Setup Guide

## Prerequisites

- Flutter SDK 3.24+
- Android Studio for Android builds
- PHP 8.1+ with PDO MySQL
- MySQL 8+ or MariaDB
- Google Maps API key if you use map screens

## 1. Flutter Setup

```powershell
cd "c:\Users\Anyame Shammah\Desktop\sawalove\sawalove"
flutter pub get
flutter doctor
```

## 2. PHP Backend Setup

The app uses the PHP API in `backend/php`.

1. Create a MySQL database.
2. Import `backend/php/schema.sql`.
3. Copy `backend/php/.env.example` to `backend/php/.env`.
4. Update `APP_URL`, `APP_KEY`, `DB_DSN`, `DB_USER`, and `DB_PASSWORD`.
5. Deploy the backend with the web document root pointed at
   `backend/php/public`.
6. Confirm this endpoint works:
   `https://your-api-domain/health`

For production phone OTP, configure `SMS_HTTP_URL` in the backend `.env`.

## 3. App Environment Values

The Flutter app reads PHP settings through Dart defines:

```text
API_BASE_URL
API_PHONE_AUTH_ENABLED
API_EMAIL_AUTH_ENABLED
API_GOOGLE_AUTH_ENABLED
API_APPLE_AUTH_ENABLED
```

For release builds, put them in `.env.release`.

For local development, run:

```powershell
flutter run `
  --dart-define=API_BASE_URL=https://your-api-domain `
  --dart-define=API_PHONE_AUTH_ENABLED=true `
  --dart-define=API_EMAIL_AUTH_ENABLED=true
```

Without `API_BASE_URL`, debug builds use demo data. Release builds require a
public HTTPS `API_BASE_URL`.

## 4. Android

- Add your Google Maps key to the Android manifest if map features are used.
- Release builds require a public HTTPS PHP API URL.
- Confirm `android/key.properties` points to the upload keystore used for Play
  Store signing.

## 5. Calls (Agora + FCM)

Video calls need four client values and three Edge Function secrets. Nothing
is checked in. Without the Agora id the video screen stays disabled; without
the FCM values calls still ring while the app is open (`CallRinger` polls for a
ringing call every few seconds) but cannot wake a closed app:

```powershell
flutter run `
  --dart-define=AGORA_APP_ID=<32-char Agora app id> `
  --dart-define=FIREBASE_API_KEY=<firebase web api key> `
  --dart-define=FIREBASE_APP_ID=1:<sender>:android:<hash> `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=<sender id> `
  --dart-define=FIREBASE_PROJECT_ID=<firebase project id>
```

`AGORA_APP_ID` gates the video call screen and the `FIREBASE_*` values gate
push; no `google-services.json` is required because the options are passed at
runtime.

Server side (`supabase secrets set`), from the project root:

```powershell
supabase secrets set AGORA_APP_ID=<32-char Agora app id>
supabase secrets set AGORA_APP_CERTIFICATE=<Agora app certificate>
supabase secrets set FCM_SERVICE_ACCOUNT="<firebase service account json, one line>"
```

Optional: `FIREBASE_PROJECT_ID` if the service account belongs to a different
project, and `ALLOWED_ORIGINS` for the functions' CORS header.

Then deploy the two functions once:

```powershell
supabase functions deploy agora-token --no-verify-jwt=false
supabase functions deploy notify-call --no-verify-jwt=false
```

Android creates the high-importance `incoming_calls` channel in
`MainActivity` at startup, and the manifest points FCM at it, so a ring buzzes
even with the app closed. The `calls` table and its RPCs come from
`supabase/migrations/20261115010000_calls.sql` (`supabase db push`).

Android builds pin NDK `26.3.11579264` (see `android/build.gradle.kts`):
`agora_rtc_engine` links its bundled `iris_rendering_android` module without
libc++, which NDK 27 rejects with `undefined symbol: operator new(unsigned
long)`. Install it once if the Android SDK reports it missing:

```powershell
sdkmanager "ndk;26.3.11579264"
```

## 6. Build Production

```powershell
.\scripts\build_release_aab.ps1
```

The release script reads `.env.release`, checks `API_BASE_URL/health`, passes
the PHP API defines to Flutter, and writes:

```text
build\app\outputs\bundle\release\app-release.aab
```

If you already verified the deployed API manually, you can skip the network
preflight:

```powershell
.\scripts\build_release_aab.ps1 -SkipApiPreflight
```
