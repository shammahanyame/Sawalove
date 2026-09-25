# SawaLove PHP API

This is the PHP backend used by the Flutter app when it is built with
`API_BASE_URL`.

## Requirements

- PHP 8.1+
- MySQL 8+ or MariaDB with JSON support
- PDO MySQL extension
- A web server pointing at `backend/php/public`

## Tests

The integration suite boots against a real MySQL database and exercises every
security-critical endpoint over HTTP (55 assertions), plus a dedicated
brute-force/rate-limit enforcement test. The security regressions these tests
permanently guard (PII leak, PIN hashing, rate limiting, ...) are documented in
[`tests/REGRESSIONS.md`](tests/REGRESSIONS.md). CI (`.github/workflows/ci.yml`)
runs the suite plus `flutter analyze` / `flutter test` on every push.

On Windows, the all-in-one runner boots an isolated throwaway MySQL on port
3307 (it never touches an installed MySQL service):

```bat
tests\run_all.bat
```

Manually (any OS):

```bash
# 1. Create a test DB and import the schema
mysql -h 127.0.0.1 -P 3307 -u root -e "create database sawalove_test;"
mysql -h 127.0.0.1 -P 3307 -u root sawalove_test < schema.sql

# 2. Start the API (AUTH_RATE_LIMIT_MAX raised so the shared suite does not
#    trip the brute-force limiter mid-run)
APP_ENV=local APP_KEY=test-key OTP_DEBUG_RESPONSE=true AUTH_RATE_LIMIT_MAX=1000 \
DB_DSN='mysql:host=127.0.0.1;port=3307;dbname=sawalove_test' \
DB_USER=sawalove DB_PASSWORD=testpass123 \
php -S 127.0.0.1:8110 -t public public/index.php

# 3. Run the suite
DB_DSN='mysql:host=127.0.0.1;port=3307;dbname=sawalove_test' \
DB_USER=sawalove DB_PASSWORD=testpass123 \
php tests/run_api_tests.php

# 4. Separately verify the rate limiter enforces (against a default-config server)
php tests/run_rate_limit_test.php http://127.0.0.1:8111
```

## Deployment (DigitalOcean App Platform)

The repo ships a `Dockerfile` and `.do/app.yaml` app spec. Deploy steps:

1. Push this repo to GitHub/GitLab.
2. In DigitalOcean: Create → App Platform → pick the repo.
3. App Platform detects the Dockerfile; the HTTP port is 8080.
4. Add a managed MySQL database (or external DB) and set env vars from
   `.env.example` (`APP_KEY`, `DB_DSN`, `DB_USER`, `DB_PASSWORD`,
   `APP_URL`, `SMS_HTTP_URL`, ...). `APP_ENV` must be `production`.
5. Attach your domain; HTTPS certificates are provisioned automatically.
6. Run `schema.sql` once against the database (fresh installs include the
   `blocks` table). For an **existing** database, also apply the files in
   `migrations/` in order (001 chat tables, 002 push tokens, 003 blocks).

Health checks hit `/health`.

## Setup

1. Create a MySQL database.
2. Import `schema.sql`.
3. Copy `.env.example` to `.env` and update the database, app URL, and secret.
4. Point the public document root to `backend/php/public`.
5. Confirm `GET https://your-api-domain/health` returns JSON with `"ok": true`.

The Flutter release build must use the same public API root:

```powershell
API_BASE_URL=https://your-api-domain
API_PHONE_AUTH_ENABLED=true
API_EMAIL_AUTH_ENABLED=true
```

## Endpoints Used By The App

- `GET /health`
- `GET /auth/providers`
- `POST /auth/phone/request`
- `POST /auth/phone/verify`
- `POST /auth/email/signup`
- `POST /auth/email/signin`
- `POST /auth/oauth/google`
- `POST /auth/oauth/apple`
- `GET /session`
- `POST /auth/signout`
- `POST /me/pin`
- `POST /me/pause`
- `POST /me/delete-request`
- `POST /me/data-export`
- `GET /users`
- `GET /users/{id}`
- `PUT /users/{id}`
- `POST /photos/profile`
- `POST /swipes` — record a like/nope/super_like; creates a match on reciprocity
- `GET /likes` — pending incoming likes ("Likes You" grid)
- `GET /matches` — active matches with last-message preview
- `GET /matches/{id}` — one match with the peer's profile
- `DELETE /matches/{id}` — unmatch (hides the conversation for the caller)
- `GET /matches/{id}/messages` — conversation history (chronological)
- `POST /matches/{id}/messages` — send a message (1-4000 chars, flood-limited)
- `POST /account/delete-request` — public web-form deletion request (Play policy)

Phone auth generates OTP records. In production, configure `SMS_HTTP_URL` to
send the code through your SMS provider. The API posts JSON:

```json
{"to":"+237600000000","message":"Your SawaLove OTP is 123456. It expires in 10 minutes."}
```

If `SMS_HTTP_AUTH_HEADER` is set, it is sent as-is, for example
`Authorization: Bearer your-token`.
