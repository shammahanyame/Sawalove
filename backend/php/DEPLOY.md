# Deploying the SawaLove Backend (DigitalOcean App Platform)

The repo ships a production Dockerfile (`backend/php/Dockerfile`) and an
App Platform spec (`backend/php/.do/app.yaml`) that provisions the API plus a
managed MySQL 8 database. Follow these steps in order.

Estimated cost: **~$20/month** (basic-xxs web service $5 + db-s-1vcpu-1gb
MySQL $15). Scale up either component later without code changes.

---

## 1. Push the repo to GitHub

```bash
cd sawalove
git config --global user.name "Your Name"      # one-time
git config --global user.email "you@example.com"
git remote add origin https://github.com/<you>/sawalove.git
git push -u origin main
```

Pushing also triggers the GitHub Actions CI workflow (backend integration
tests + flutter analyze/test).

## 2. Create the App Platform app

After creating your DigitalOcean account:

```bash
# one-time: install doctl and authenticate
doctl auth init

# create the app + managed MySQL from the committed spec
doctl apps create --spec backend/php/.do/app.yaml
```

Alternatively: dashboard → **Create App** → **Deploy from App Spec** and
paste `backend/php/.do/app.yaml`, or click through the GitHub repo picker and
set `dockerfile_path: backend/php/Dockerfile`, `source_dir: backend/php`
(the Docker build context — COPY paths in the Dockerfile are relative to it),
`http_port: 8080`, health check `/health`.

## 3. Import the database schema

The managed database only accepts connections from trusted sources. Add your
IP first (dashboard → Databases → your cluster → **Trusted Sources**), then:

```bash
# grab the connection pool details from the dashboard (Connection Details)
mysql -h <DB_HOST> -P <DB_PORT> -u doadmin -p <DB_NAME> < backend/php/schema.sql

mysql -h <DB_HOST> -P <DB_PORT> -u doadmin -p <DB_NAME> \
  -e "show tables; show events;"
# expect: users, sessions, phone_otps, profile_photos, account_deletion_requests,
#         data_export_requests, auth_rate_limits, ai_usage, reports,
#         moderation_actions, swipes, matches, messages, blocks, push_tokens
#         + 6 housekeeping events
# Existing databases: also apply migrations/ in order (001, 002, 003).
```

Already deployed an older schema? Re-importing is destructive; instead apply
just the chat migration:

```bash
mysql -h <DB_HOST> -P <DB_PORT> -u doadmin -p <DB_NAME> < backend/php/migrations/001_chat_tables.sql
```

## 4. Set the real secrets (before launch)

Dashboard → your app → **Settings → sawalove-api → Environment Variables**
(mark each as *Encrypted*):

| Variable | How to generate |
|---|---|
| `APP_KEY` | `php -r "echo bin2hex(random_bytes(32));"` — signs rate-limit IP hashes; rotating it is safe (only affects in-flight buckets) |
| `SMS_HTTP_URL` | Your SMS gateway endpoint |
| `SMS_HTTP_AUTH_HEADER` | e.g. `Authorization: Bearer <token>` |

Also rotate `DB_PASSWORD` there if you prefer not to use the generated one.

> `OTP_DEBUG_RESPONSE` must stay `false` in production (it is in the spec).

## 5. Verify the deployment

```bash
curl https://<app-url>/health
# {"ok":true,"service":"sawalove-php-api","time":"..."}
```

The app is unhealthy by design until the DB schema exists and `APP_KEY` is
set — `/health` runs a live `select 1` against MySQL.

## 6. Point the Flutter app at the live API

```bash
# in sawalove/.env.release
API_BASE_URL=https://<app-url>       # or your custom domain

.\scripts\build_release_aab.ps1      # rebuilds and re-verifies the AAB
```

## 7. (Optional) Custom domain

Dashboard → app → **Settings → Domains** → add `api.your-domain.com` and
create the `CNAME` it shows you. HTTPS certificates are provisioned
automatically. Then set `APP_URL=https://api.your-domain.com` so photo URLs
and links use it.

---

## Known limitation: photo storage

App Platform **services** have an ephemeral container filesystem (persistent
volumes are only available to workers/jobs), so uploaded profile photos are
lost on every redeploy. Recommended follow-ups, in order of effort:

1. **Object storage (recommended)** — add a DigitalOcean Spaces bucket, move
   `store_profile_photo()`/photo deletion in `src/app.php` to the S3 API,
   and serve images from the Spaces CDN URL.
2. **Worker + volume** — move uploads behind a worker component with a
   mounted volume and a small proxy.
3. **Accept re-uploads** — fine for early testing only.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Health check fails, deploy rolls back | Check **Runtime Logs** — usually missing schema (step 3) or `APP_KEY` not set (step 4) |
| `500` on every endpoint | `APP_KEY` or DB env vars missing/typo |
| OTPs never arrive | `SMS_HTTP_URL`/`SMS_HTTP_AUTH_HEADER` placeholders still set |
| Build fails at image build | Ensure the repo root contains `backend/php/` (spec uses `dockerfile_path: backend/php/Dockerfile`) |
| `429 too_many_requests` in testing | Brute-force limiter doing its job; wait for the window or raise `AUTH_RATE_LIMIT_MAX` |
