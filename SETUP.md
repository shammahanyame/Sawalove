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

## 5. Build Production

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
