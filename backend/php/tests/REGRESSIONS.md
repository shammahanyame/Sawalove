# Security Regressions — Permanent CI Fixtures

Every item below was a **real vulnerability or bug** found in this codebase.
The integration suite (`tests/run_api_tests.php`) now contains a test that
fails if the bug ever comes back. CI runs the suite on every push, so these
regressions can never silently reappear.

Run everything locally with `tests\run_all.bat` (Windows) or the manual steps
in `backend/php/README.md`.

---

## 1. PII leak on public profile endpoints

| | |
|---|---|
| **The bug** | `user_to_api()` returned `email` and `phone` for **every** user. `GET /users` and `GET /users/{id}` were unauthenticated, so anyone could harvest all phone numbers and email addresses. |
| **The risk** | Mass profile scraping, SIM-swap phishing, spam — critical for a dating app. |
| **The fix** | Contact fields are only included when `includePrivate=true`, which handlers pass **only** for the authenticated owner (`handle_session`, `handle_get_user` when self, `handle_update_user`, sign-in/verify responses). |
| **Guard tests** | `GET /users never leaks email/phone` · `other authenticated user cannot see email/phone` · `anonymous cannot see email/phone on public profile` · `owner sees own email` |

## 2. Unsalted client-side PIN hash

| | |
|---|---|
| **The bug** | The app hashed the PIN client-side with plain `sha256()` and the backend stored the result as-is. A 6-digit PIN has only 1,000,000 combinations — one precomputed rainbow table recovers **every** user's PIN instantly. |
| **The fix** | The raw PIN is sent over TLS; the backend stores `password_hash()` (bcrypt, per-user random salt) and enforces a strength policy (no repeated/sequential digits). |
| **Guard tests** | `repeated/sequential/3-digit PIN rejected` · `PIN stored with password_hash (salted, not sha256)` · `stored hash verifies against the PIN` · `stored hash is NOT unsalted sha256 of PIN` (inspects the actual DB row) |

## 3. No brute-force protection on credential endpoints

| | |
|---|---|
| **The bug** | `/auth/email/signin` and `/auth/email/signup` had no rate limiting at all — unlimited password guessing. Only the phone-OTP path had a per-phone cap. |
| **The fix** | Fixed-window per-IP counters in `auth_rate_limits` (default 20 attempts / 5 min, tunable via `AUTH_RATE_LIMIT_WINDOW` / `AUTH_RATE_LIMIT_MAX`), with `Retry-After` on 429 and fail-open on DB errors so the limiter can't take auth down. |
| **Guard tests** | `auth_rate_limits rows were recorded during the run` plus the dedicated enforcement test `tests/run_rate_limit_test.php`, which asserts a 429 arrives after the window fills (and not before 5 attempts). |

## 4. OTP debug codes exposed outside local development

| | |
|---|---|
| **The bug** | `debug_code` (the raw SMS code) was returned in the API response for **any** non-production environment — staging included. Anyone with network access to a staging API could sign in as any phone user. |
| **The fix** | The code is returned only when `OTP_DEBUG_RESPONSE=true` is explicitly set; never implicitly. |
| **Guard tests** | `debug OTP only present when OTP_DEBUG_RESPONSE=true` (suite runs with it enabled) — combined with the deployment checklist keeping it `false` in staging/prod. |

## 5. OTP replay

| | |
|---|---|
| **The bug** | Weakness risk around code reuse: consumed codes and attempt caps must be enforced atomically. |
| **The fix** | Codes are marked `consumed_at` on first successful verify; subsequent verifies of the same code are rejected. Per-OTP attempt counter caps guessing. |
| **Guard tests** | `wrong OTP rejected with 400` · `correct OTP signs in / creates user` · `OTP replay rejected after consumption` |

## 6. Malicious profile photo URLs (stored XSS / SSRF vector)

| | |
|---|---|
| **The bug** | `PUT /users/{id}` accepted any string as `photo`, including `javascript:` URIs and arbitrary attacker-hosted URLs that clients would happily render. |
| **The fix** | Only `http(s)` URLs on the API's own host or hosts in `UPLOAD_ALLOWED_HOSTS` are accepted; production additionally requires https. |
| **Guard tests** | `javascript: photo URL rejected` · `photo URL on non-allowed host rejected` |

## 7. User enumeration on sign-in

| | |
|---|---|
| **The bug** | Unknown emails and wrong passwords could produce distinguishable responses/timings. |
| **The fix** | Uniform `401 invalid_credentials` body for both cases; password verification runs against a dummy-safe path so unknown users take comparable work. |
| **Guard tests** | `unknown email returns identical 401 (no enumeration)` compares the full response body byte-for-byte. |

## 8. Upload directory script execution

| | |
|---|---|
| **The bug** | Uploaded files landed under the web root with no execution guard — a disguised `.php` upload (if MIME checks were ever bypassed) could execute. |
| **The fix** | MIME is detected with `finfo` (not client-supplied names), extensions are derived from the detected MIME, and `ensure_uploads_htaccess()` writes an Apache config blocking script execution in the uploads tree. The Docker image also serves only `public/`. |
| **Guard tests** | Covered structurally (MIME allow-list is enforced in every upload path); the `.htaccess` guard is defense-in-depth, verified in the Docker/deployment review. |

## 9. Missing security headers

| | |
|---|---|
| **The fix** | `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: no-referrer`, `Permissions-Policy`, and HSTS in production are sent on every response. |
| **Guard tests** | `security headers present` · `referrer policy header present` |

## 10. Misc correctness bugs caught by the suite

- `error_log(Throwable)` fatals on PHP 8 → HTML error pages instead of JSON (guard: JSON error contract asserted throughout).
- `user_to_api()` built `$data` but never returned it → 500 on signup/sign-in (guard: every session-issuing test).
- Housekeeping events in `schema.sql` used `BEGIN…END` blocks that plain `mysql <` imports choke on → rewritten as single-statement events (guard: CI imports `schema.sql` verbatim before running the suite).
- Lat/lng/distance accepted arbitrary floats → bounds-validated (guard: `latitude > 90 rejected`, `longitude < -180 rejected`).
- Input length caps on name/email/password/country to match DB columns (guard: signup validation matrix).

---

## Adding a new guard

1. Fix the bug first.
2. Add a test in `tests/run_api_tests.php` using `check($result, 'name', $condition, $detail)` that **fails on the old code** — a regression test that passes both ways protects nothing.
3. Verify by temporarily reverting your fix and watching the suite fail.
4. Add an entry to this file under the matching section.

CI fails on any regression; do not disable a guard to make a build pass —
delete the *vulnerability*, not the test.
