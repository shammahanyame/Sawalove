<?php

declare(strict_types=1);

/**
 * Rate-limit enforcement test.
 *
 * Hammers POST /auth/email/signin until the per-IP fixed window rejects with
 * 429. Run against a server with PRODUCTION defaults (AUTH_RATE_LIMIT_MAX
 * unset so it defaults to 20):
 *
 *   APP_ENV=local APP_KEY=test-key DB_DSN='mysql:host=127.0.0.1;port=3307;dbname=sawalove_test' \
 *   DB_USER=sawalove DB_PASSWORD=testpass123 \
 *   php -S 127.0.0.1:8111 -t public public/index.php
 *
 *   php tests/run_rate_limit_test.php http://127.0.0.1:8111
 */

$baseUrl = rtrim($argv[1] ?? 'http://127.0.0.1:8111', '/');

function post(string $url, array $body): int
{
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => 'POST',
        CURLOPT_HTTPHEADER => ['Content-Type: application/json', 'Accept: application/json'],
        CURLOPT_POSTFIELDS => json_encode($body),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 10,
    ]);
    curl_exec($ch);
    $status = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    return $status;
}

$ok = 0;
$sawThrottle = false;
for ($i = 1; $i <= 60; $i++) {
    $status = post($baseUrl . '/auth/email/signin', [
        'email' => 'ratelimit-probe@example.com',
        'password' => 'wrong-password-' . $i,
    ]);
    if ($status === 429) {
        $sawThrottle = true;
        echo "Rate limit tripped after {$ok} unthrottled attempts (429 at request #{$i}).\n";
        break;
    }
    if ($status === 401) {
        $ok++;
    } else {
        echo "Unexpected status {$status} at attempt #{$i}\n";
        exit(1);
    }
}

if (!$sawThrottle) {
    echo "FAIL: no 429 after 60 attempts — brute-force protection is NOT enforcing.\n";
    exit(1);
}

if ($ok < 5) {
    echo "FAIL: throttle tripped too early ({$ok} allowed attempts) — check window config.\n";
    exit(1);
}

echo "PASS: brute-force protection enforced (allowed {$ok} attempts, then 429).\n";
exit(0);
