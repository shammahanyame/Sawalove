# SawaLove — Google Play Launch Checklist

Last updated: 2026-09-25 · Version 1.0.1+3 · applicationId `com.shammah.sawalove`

Work through every section before pressing "Submit for review". Items marked
**BLOCKER** cause automatic rejection or a broken app for users.

---

## 0. Before anything else — BLOCKERS

| # | Item | Status |
|---|------|--------|
| 0.1 | **Deploy the PHP API.** `.env.release` points at `https://api.sawalove-app.com` but the domain does not resolve (the build script's preflight caught this). Deploy `backend/php` (DigitalOcean guide in `backend/php/README.md`), run `schema.sql`, and confirm `GET https://<your-domain>/health` returns `{"ok": true}`. | ⬜ TODO |
| 0.2 | **Update `.env.release`** with the real deployed `API_BASE_URL`, then rebuild: `powershell -File scripts/build_release_aab.ps1` (preflight must pass — do NOT use `-SkipApiPreflight` for the submission build). | ⬜ TODO |
| 0.3 | **Upload legal documents** to `https://sawalove.com/privacy.pdf` and `https://sawalove.com/tos.pdf` (the consent screen links to these). PDFs are ready: `legal_exports/privacy-policy-en.pdf` + `legal_exports/terms-of-service-en.pdf` (FR variants alongside; regenerate any time with `python scripts/export_legal_pdfs.py` after editing `lib/core/utils/legal_documents.dart`). Also host the privacy policy at a public URL for the Play Console "Privacy Policy" field. | ⬜ TODO |
| 0.4 | **Rotate secrets.** A `.env.release` with real values sits on disk and previously existed in the workspace; treat it as compromised. Rotate any API keys it contains (SMS provider, AI gateway, etc.). Keystore is fine (never committed). | ⬜ TODO |
| 0.5 | **Fix the Google Maps API key** — `android/app/src/main/res/values/strings.xml` still contains `YOUR_GOOGLE_MAPS_API_KEY`. Either supply a real key (restricted to `com.shammah.sawalove`) or leave it; the nearby-map screen is gated off in release so nothing calls Maps yet. | ⬜ TODO |

---

## 1. Play Console setup

### 1.1 App category & tags
- Category: **Dating**
- Tags: Dating, Social

### 1.2 Content rating (IARC questionnaire)
Answer honestly; expected outcomes:
- Sex/nudity: **Mild** (profiles, user photos — no explicit content allowed by your ToS)
- Language: Mild
- Controlled substances: None
- User interaction: **Yes — users interact and share content** (triggers the UGC questionnaire)
- Expected rating: **Mature 17+ / Adults only 18+** depending on region questionnaire
- **BLOCKER**: the app must be rated 18+ for the Dating category. If the questionnaire yields a lower rating, re-check answers about user-generated content.

### 1.3 Target audience & content
- Target age group: **18 and up only** (do NOT tick any group including under-18s)
- "Is your app designed for children?" → **No**
- Appeal to children → **No**
- This matches the in-app 18+ age gate (`/age-gate` before signup).

### 1.4 Data safety form (Play Console → App content → Data safety)

Paste-ready version: `PLAY_STORE_LISTING.md` §6.

Answer these exactly — they match the app + PHP backend as built:

**Does your app collect or share any of the required user data types?** → Yes

| Data type | Collected? | Shared? | Purpose | Ephemeral? | Required? |
|---|---|---|---|---|---|
| Phone number | Yes | No | Account management, app functionality | No | Optional (user can use email) |
| Email address | Yes | No | Account management | No | Optional (user can use phone) |
| Name | Yes | No | App functionality (profile display) | No | Yes |
| User IDs | Yes | No | Account management, analytics opt-in | No | Yes |
| Photos | Yes | No | App functionality (profile) | No | Yes |
| Other user content (bio, preferences) | Yes | No | App functionality | No | Yes |
| Approximate location | Yes | No | App functionality (matching) | No | Yes (in-app disclosure given) |
| Messages (chat) | Yes — chat is live (server stores conversations) | No | App functionality | No | Yes |
| App interactions | Only if analytics consent given | No | Analytics | No | Optional |

- Data encrypted in transit: **Yes** (HTTPS enforced; `usesCleartextTraffic=false`)
- Users can request data deletion: **Yes** (in-app: Profile → Account → Delete; also `support@sawalove.cm`)
- Data deletion URL: `https://sawalove.com/deletion` (host a short page; can redirect to the policy)
- Data sold: **No** · Data shared with third parties: **No**
- Committed to Google Play Families Policy? → **No** (adults-only app)

### 1.5 Account deletion (policy requirement for apps with account creation)
- In-app path exists: Profile → Account → Delete Account ✅
- Play Console requires **both** an in-app path **and** a web link. Host a simple form/page at `https://sawalove.com/deletion` that triggers the same server-side deletion. **BLOCKER if missing.**

### 1.6 Privacy policy
- Paste policy text (from `lib/core/utils/legal_documents.dart`) to a public URL, e.g. `https://sawalove.com/privacy`
- Provide that URL in Play Console → App content → Privacy policy. **BLOCKER if missing.**

### 1.7 App access — CRITICAL for review
- "All or some functionality is restricted?" → **All functionality is available** if phone OTP works for the reviewer.
- **BLOCKER**: phone auth requires a Cameroonian SMS code. Provide ONE of:
  1. Full instructions + a working test phone number the reviewer can use, or
  2. A pre-made demo account (email + password) using email sign-in, with credentials in the "App access" form.
- The backend must have OTP sending live (`SMS_HTTP_URL` configured) before you submit.

### 1.8 Ads declaration
- Contains ads? → **No**

### 1.9 News app declaration
- Is this a news app? → **No**

### 1.10 COVID-19 / government apps
- No.

---

## 2. Store listing

**Paste-ready copy: `PLAY_STORE_LISTING.md`** — app name (≤30 chars), short
& full descriptions in EN+FR, screenshots plan, Data safety answers, and the
App access template. The bullets below are the guardrails for it.

- App name: `SawaLove — Rencontres au Cameroun` (≤30 chars; adjust as you prefer, keep it truthful)
- Short description (≤80 chars), suggested EN: `Find your soulmate in Cameroon. Real profiles, real people, 18+.`
  Suggested FR: `Trouvez votre âme sœur au Cameroun. De vrais profils, 18+.`
- Full description: describe what actually works in v1.0.1: profile creation, photo uploads, discovery/matching, filters, **messaging (1-to-1 chat with matches)**, likes & matches, reporting & blocking, account deletion. Do NOT mention calls, premium, verification badges, SOS, super likes, or referral rewards — they are disabled and reviewers test claims.
- Screenshots: phone (min 2, recommended 8): onboarding, discovery, filters, profile, safety center, consent screen (shows compliance).
- Feature graphic 1024×500, app icon 512×512 (have: `assets/branding/sawalove_app_icon_512.png`).
- Translations: add `fr-FR` store listing (Cameroon is bilingual; default listing can be EN).

---

## 3. Release build & technical checklist

| # | Item | Status |
|---|---|---|
| 3.1 | versionCode 3 / versionName 1.0.1 (`pubspec.yaml`) — bump before each submission | ✅ |
| 3.2 | Target SDK 36, min SDK 24 (from AAB manifest) | ✅ |
| 3.3 | 64-bit + all ABIs included (base/lib/ has 12 entries incl. arm64-v8a, armeabi-v7a, x86_64) | ✅ |
| 3.4 | Signed with upload keystore (`android/key.properties`, Play App Signing: enroll and upload the AAB) | ✅ |
| 3.5 | Release guards active: build fails if `SHIP_COMPLETE_FEATURES_ONLY=false` or `SHOW_PREMIUM=true` | ✅ |
| 3.6 | No cleartext traffic (`usesCleartextTraffic=false`), API_BASE_URL enforced https by Gradle | ✅ |
| 3.7 | `flutter analyze` clean, `flutter test` 20/20 pass | ✅ |
| 3.8 | Permissions minimal: INTERNET, NETWORK_STATE, CAMERA, RECORD_AUDIO, FINE+COARSE_LOCATION, POST_NOTIFICATIONS, VIBRATE — all with in-app rationale | ✅ |
| 3.9 | **BLOCKER**: rebuild the AAB with the real deployed `API_BASE_URL` (see 0.2). The AAB built for this verification contains the not-yet-live domain and is NOT the submission candidate. | ⬜ TODO |
| 3.10 | Release AAB build verified end-to-end (2026-09-25): `build_release_aab.ps1 -SkipApiPreflight` exits 0, Flutter's debug-symbol strip check passes (`libflutter.so.sym` present for all 3 ABIs in `BUNDLE-METADATA`), signer cert SHA-256 matches `android/upload-keystore.jks` (upload key, not debug), manifest = `com.shammah.sawalove` / versionCode 3 / 1.0.1 / minSdk 24 / targetSdk 36 / cleartext off, 12 native `.so` (arm64-v8a, armeabi-v7a, x86_64), `API_BASE_URL` compiled into `libapp.so`. | ✅ |

Build command for the submission candidate:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_release_aab.ps1
```
(The script health-checks the API first — let it.)

> **Machine note (rebuilds on this Windows box):** `android/local.properties` sets
> `sdk.dir=C:\Android\sdk` — a directory junction to the real SDK. The real SDK path contains a
> space in the Windows username, which crashes `apkanalyzer` and fails Flutter's post-build
> debug-symbol verification. Keep the junction (or any other space-free SDK path) or the release
> build will fail at the strip check. `scripts/build_release_aab.ps1` sets `JAVA_HOME` itself from
> `android/gradle.properties` (`org.gradle.java.home` → Android Studio JBR, Java 21), which
> `apkanalyzer` also requires.

---

## 4. Policies your app must demonstrably satisfy (reviewer-facing)

| Policy | How SawaLove satisfies it now |
|---|---|
| Dating apps: 18+, UGC moderation | Age gate with DOB block (`/age-gate`); report flow → server moderation queue with pause/ban/reinstate; appeal path; ToS community rules |
| Account deletion | In-app 30-day deletion flow + data export |
| Data safety accuracy | Section 1.4 above matches actual collection |
| Deceptive behaviour | All fake/sham features removed or gated behind "Coming soon" in release builds |
| Payments (deferred) | No paid features shipped; Gradle blocks re-enabling premium until Play Billing is integrated |
| Device & network abuse | No background services; standard permissions only |
| Screen/recording permission abuse | RECORD_AUDIO used only for voice notes (feature disabled in release) |

---

## 5. Feature status — chat & likes/matches are SHIPPED

**Enabled (always on, backed by real API endpoints):**
- `kShowChat` = `true` — messaging works end-to-end (`GET/POST /matches/{id}/messages`, `DELETE /matches/{id}` unmatch, report/block from the chat menu pass real user ids).
- `kShowLikesAndMatches` = `true` — the Likes tab renders `GET /likes`; Matches renders `GET /matches`; both are wired into the Notifications screen too.
- Sticker picker in chat sends real emoji messages. The GIF tab was removed — it had no API behind it and could only ever show an empty grid (a fake feature).
- Blocking is real: `POST/DELETE /users/{id}/block`, `GET /blocks`; blocked pairs disappear from discovery, likes, matches, and chat in both directions (backend suite: 113 assertions).
- Discovery excludes self/already-swiped/blocked users server-side and applies the filter sheet client-side (age, photo, faith, intent, region, distance when both profiles have coordinates).

Data safety (section 1.4) already lists **Messages = collected** — keep it that way. Store listing (section 2) must mention messaging.

**Still gated (no backend / needs work):**
- **Super Like** (`kShowSuperLike`): server records `super_like` swipes, but there is no notification/queue surfaced to recipients yet.
- **Nearby map** (`kShowNearbyMap`): requires a real Maps API key + backend locations.
- **Premium** (`kShowPremium`): **must** use Google Play Billing; the Gradle guard hard-blocks this define in release until then.
- **Calls** (`kShowCalls`): integrate Agora with a real App ID + token service; remove `YOUR_AGORA_APP_ID` placeholder.
- **SOS / ID verification** (`kShowSos`, `kShowIdVerification`): need real backend + legal review of government-ID handling (NIN storage has serious data-protection requirements).

**Known limitations (honest UI, no fake data):**
- Filter-sheet chips with no backing data (gender, online-now, lifestyle) are shown but not enforced — the API has no such fields yet; do not advertise them in the listing.
- Invite-friends screen only copies a real Play Store link — there is no referral attribution backend, so no rewards are promised.
- Voice-note and video-call screens still contain demo personas, but they are unreachable/gated in release builds (chat is text-only server-side).
