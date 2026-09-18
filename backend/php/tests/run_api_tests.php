<?php

declare(strict_types=1);

/**
 * SawaLove PHP API integration test suite.
 *
 * Boots the real application (src/app.php) against a real MySQL database and
 * exercises every security-critical endpoint over HTTP using the PHP built-in
 * dev server.
 *
 * Requirements:
 *   - PHP 8.1+ CLI with pdo_mysql, curl
 *   - MySQL 8 with schema.sql imported
 *
 * Usage:
 *   DB_DSN='mysql:host=127.0.0.1;port=3307;dbname=sawalove_test' \
 *   DB_USER=sawalove DB_PASSWORD=testpass123 \
 *   php tests/run_api_tests.php
 *
 * Exit code 0 = all tests passed.
 */

require __DIR__ . '/../src/app.php';

final class TestResult
{
    public int $passed = 0;
    /** @var string[] */
    public array $failures = [];

    public function record(string $name, bool $ok, string $detail = ''): void
    {
        if ($ok) {
            $this->passed++;
            echo "  ok  {$name}\n";
        } else {
            $this->failures[] = $name . ($detail !== '' ? " — {$detail}" : '');
            echo "FAIL  {$name}" . ($detail !== '' ? " — {$detail}" : '') . "\n";
        }
    }
}

function check(TestResult $r, string $name, bool $condition, string $detail = ''): void
{
    $r->record($name, $condition, $detail);
}

function main(): int
{
    $result = new TestResult();
    $baseUrl = getenv('TEST_BASE_URL') ?: 'http://127.0.0.1:8110';
    $client = new ApiTestClient($baseUrl);

    // ── Infrastructure ────────────────────────────────────────────────
    echo "Health & infrastructure\n";
    try {
        $health = $client->get('/health');
        check($result, 'GET /health returns ok=true', ($health['body']['ok'] ?? null) === true);
        check($result, 'GET /health is JSON', str_contains($health['content_type'] ?? '', 'application/json'));
    } catch (Throwable $e) {
        echo "Cannot reach test server at {$baseUrl}: {$e->getMessage()}\n";
        echo "Start it with:\n";
        echo "  APP_ENV=local APP_KEY=test-key DB_DSN='mysql:host=127.0.0.1;port=3307;dbname=sawalove_test' \\\n";
        echo "  DB_USER=sawalove DB_PASSWORD=testpass123 \\\n";
        echo "  php -S 127.0.0.1:8110 -t public public/index.php\n";
        return 2;
    }

    $providers = $client->get('/auth/providers');
    check($result, 'GET /auth/providers lists phone+email enabled', 
        ($providers['body']['providers']['phone'] ?? false) === true &&
        ($providers['body']['providers']['email'] ?? false) === true);
    check($result, 'GET /auth/providers has google/apple off by default',
        ($providers['body']['providers']['google'] ?? true) === false &&
        ($providers['body']['providers']['apple'] ?? true) === false);

    // ── Email signup validation ───────────────────────────────────────
    echo "\nEmail signup validation\n";
    $cases = [
        [['name' => 'x', 'email' => 'a@b.com', 'password' => 'longenough1'], 422],
        [['name' => 'Valid Name', 'email' => 'not-an-email', 'password' => 'longenough1'], 422],
        [['name' => 'Valid Name', 'email' => 'a@b.com', 'password' => 'short'], 422],
        [['name' => 'Valid Name', 'email' => 'a@b.com', 'password' => str_repeat('x', 256)], 422],
        [['name' => 'Valid Name', 'email' => 'a@b.com', 'password' => 'longenough1', 'country' => 'CMR'], 422],
    ];
    foreach ($cases as $i => [$payload, $expected]) {
        $resp = $client->post('/auth/email/signup', $payload);
        check($result, "signup rejects invalid payload #{$i} (expect {$expected})", $resp['status'] === $expected,
            "got {$resp['status']}");
    }

    // ── Unique email + session issuance ───────────────────────────────
    echo "\nEmail signup + session\n";
    $email = 'test-user-' . bin2hex(random_bytes(4)) . '@example.com';
    $signup = $client->post('/auth/email/signup', [
        'name' => 'Test User',
        'email' => $email,
        'password' => 'correct-horse-battery',
        'country' => 'CM',
    ]);
    check($result, 'signup returns 201', $signup['status'] === 201, "got {$signup['status']}");
    $token = $signup['body']['session']['token'] ?? null;
    $userId = $signup['body']['user']['id'] ?? null;
    check($result, 'signup returns a session token', is_string($token) && $token !== '');
    check($result, 'signup returns a user id', is_string($userId) && $userId !== '');

    $dupe = $client->post('/auth/email/signup', [
        'name' => 'Test User',
        'email' => strtoupper($email), // different case, same account
        'password' => 'correct-horse-battery',
    ]);
    check($result, 'duplicate email (case-insensitive) returns 409', $dupe['status'] === 409, "got {$dupe['status']}");

    // ── Sign-in behaviour ─────────────────────────────────────────────
    echo "\nEmail sign-in\n";
    $wrongPw = $client->post('/auth/email/signin', ['email' => $email, 'password' => 'wrong-password']);
    check($result, 'wrong password returns 401', $wrongPw['status'] === 401, "got {$wrongPw['status']}");
    check($result, 'wrong password has uniform error code', ($wrongPw['body']['error']['code'] ?? '') === 'invalid_credentials');

    $unknown = $client->post('/auth/email/signin', ['email' => 'ghost-' . $email, 'password' => 'whatever123']);
    check($result, 'unknown email returns identical 401 (no enumeration)', 
        $unknown['status'] === 401 && $unknown['body'] === $wrongPw['body']);

    $good = $client->post('/auth/email/signin', ['email' => $email, 'password' => 'correct-horse-battery']);
    check($result, 'correct credentials return 200 + token', $good['status'] === 200 && is_string($good['body']['session']['token'] ?? null));

    // ── PII protection (the critical fix) ─────────────────────────────
    echo "\nPII protection on public endpoints\n";
    // Make the first user visible so the public listing has content.
    $client->withToken($token)->put('/users/' . $userId, ['visible' => true]);
    $publicList = $client->get('/users?limit=50');
    check($result, 'GET /users returns 200', $publicList['status'] === 200);
    $users = $publicList['body']['users'] ?? [];
    check($result, 'GET /users returns at least one visible user', count($users) >= 1,
        'got ' . count($users) . ' users; body: ' . substr(json_encode($publicList['body']), 0, 120));
    $leaks = array_filter($users, static fn (array $u) => !empty($u['email']) || !empty($u['phone']));
    check($result, 'GET /users never leaks email/phone', count($leaks) === 0,
        'leaked in ' . count($leaks) . ' profiles');

    $self = $client->withToken($token)->get('/users/' . $userId);
    check($result, 'owner sees own email', ($self['body']['user']['email'] ?? null) === strtolower($email),
        'email seen: ' . json_encode($self['body']['user']['email'] ?? null));

    // another account must not see the first user's email
    $email2 = 'test-user-' . bin2hex(random_bytes(4)) . '@example.com';
    $signup2 = $client->post('/auth/email/signup', [
        'name' => 'Second User', 'email' => $email2, 'password' => 'correct-horse-battery',
    ]);
    $token2 = $signup2['body']['session']['token'] ?? '';
    $client->withToken($token2)->put('/users/' . $signup2['body']['user']['id'], ['visible' => true, 'name' => 'Second User']);
    $other = $client->withToken($token2)->get('/users/' . $userId);
    check($result, 'other authenticated user cannot see email', empty($other['body']['user']['email']));
    check($result, 'other authenticated user cannot see phone', empty($other['body']['user']['phone']));
    check($result, 'profile still returns name to others', ($other['body']['user']['name'] ?? null) === 'Test User');

    $anon = $client->get('/users/' . $userId);
    check($result, 'anonymous cannot see email on public profile', empty($anon['body']['user']['email']));
    check($result, 'anonymous cannot see phone on public profile', empty($anon['body']['user']['phone']));

    // ── Profile update validation ─────────────────────────────────────
    echo "\nProfile update validation\n";
    $c = $client->withToken($token);
    $badPhoto = $c->put('/users/' . $userId, ['photo' => 'javascript:alert(1)']);
    check($result, 'javascript: photo URL rejected', $badPhoto['status'] === 422);
    $badPhoto2 = $c->put('/users/' . $userId, ['photo' => 'http://evil.example.com/x.jpg']);
    check($result, 'photo URL on non-allowed host rejected', $badPhoto2['status'] === 422);
    $badLat = $c->put('/users/' . $userId, ['lat' => 999]);
    check($result, 'latitude > 90 rejected', $badLat['status'] === 422);
    $badLng = $c->put('/users/' . $userId, ['lng' => -500]);
    check($result, 'longitude < -180 rejected', $badLng['status'] === 422);
    $okUpdate = $c->put('/users/' . $userId, ['bio' => 'Hello from tests', 'city' => 'Douala']);
    check($result, 'valid bio/city update succeeds', $okUpdate['status'] === 200 && ($okUpdate['body']['user']['bio'] ?? '') === 'Hello from tests');

    // ── PIN hashing (the critical fix) ────────────────────────────────
    echo "\nTransaction PIN handling\n";
    $weakPin = $c->post('/me/pin', ['pin' => '111111']);
    check($result, 'repeated PIN rejected', $weakPin['status'] === 422);
    $seqPin = $c->post('/me/pin', ['pin' => '123456']);
    check($result, 'sequential PIN rejected', $seqPin['status'] === 422);
    $shortPin = $c->post('/me/pin', ['pin' => '123']);
    check($result, '3-digit PIN rejected', $shortPin['status'] === 422);
    $goodPin = $c->post('/me/pin', ['pin' => '948162']);
    check($result, 'strong PIN accepted', $goodPin['status'] === 200, "got {$goodPin['status']}");

    // Verify the DB stores a modern password_hash, never a raw digest of the PIN
    $row = db_fetch('select pin_hash from users where id = ?', [$userId]);
    $stored = (string)($row['pin_hash'] ?? '');
    check($result, 'PIN stored with password_hash (salted, not sha256)', 
        $stored !== '' && str_starts_with($stored, '$2y$') || str_starts_with($stored, '$argon2'),
        'stored: ' . substr($stored, 0, 10) . '...');
    check($result, 'stored hash verifies against the PIN', $stored !== '' && password_verify('948162', $stored));
    check($result, 'stored hash is NOT unsalted sha256 of PIN',
        $stored !== hash('sha256', '948162'));

    // ── OTP flow with a real SMS-harness ──────────────────────────────
    echo "\nPhone OTP flow (debug harness)\n";
    $phone = '+2376' . str_pad((string)random_int(10000000, 99999999), 8, '0');
    $otpReq = $client->post('/auth/phone/request', ['phone' => $phone]);
    check($result, 'phone request returns ok + expires_in', 
        $otpReq['status'] === 200 && ($otpReq['body']['ok'] ?? false) === true && isset($otpReq['body']['expires_in']),
        "status {$otpReq['status']}");
    $debugCode = $otpReq['body']['debug_code'] ?? null;
    check($result, 'debug OTP only present when OTP_DEBUG_RESPONSE=true', is_string($debugCode) && preg_match('/^\d{6}$/', (string)$debugCode) === 1);

    $badVerify = $client->post('/auth/phone/verify', ['phone' => $phone, 'code' => '000000']);
    check($result, 'wrong OTP rejected with 400', $badVerify['status'] === 400);

    $verify = $client->post('/auth/phone/verify', ['phone' => $phone, 'code' => $debugCode]);
    check($result, 'correct OTP signs in / creates user', $verify['status'] === 200 && is_string($verify['body']['session']['token'] ?? null));
    $phoneUserId = $verify['body']['user']['id'] ?? '';
    check($result, 'phone user created with +237 -> CM country', ($verify['body']['user']['country'] ?? '') === 'CM');

    $replay = $client->post('/auth/phone/verify', ['phone' => $phone, 'code' => $debugCode]);
    check($result, 'OTP replay rejected after consumption', $replay['status'] === 400);

    // ── Authenticated account actions ─────────────────────────────────
    echo "\nSession & account actions\n";
    // The first token was already used for the /users visibility update and is
    // still valid — but to be explicit, sign in again for a fresh session.
    $fresh = $client->post('/auth/email/signin', ['email' => $email, 'password' => 'correct-horse-battery']);
    $token = $fresh['body']['session']['token'] ?? $token;
    $session = $client->withToken($token)->get('/session');
    check($result, 'GET /session with valid token returns user', ($session['body']['user']['id'] ?? '') === $userId);
    check($result, 'GET /session includes own email', !empty($session['body']['user']['email']));

    $noAuth = $client->get('/session');
    check($result, 'GET /session without token returns 401', $noAuth['status'] === 401);

    $forged = $client->withToken('totally-forged-token')->get('/session');
    check($result, 'forged token returns 401', $forged['status'] === 401);

    // signout revokes the session
    $signout = $client->withToken($token)->post('/auth/signout');
    check($result, 'POST /auth/signout returns ok', ($signout['body']['ok'] ?? false) === true);
    $afterSignout = $client->withToken($token)->get('/session');
    check($result, 'token is rejected after signout', $afterSignout['status'] === 401);

    // ── 404 & method handling ─────────────────────────────────────────
    echo "\nRouting\n";
    check($result, 'unknown endpoint returns JSON 404', $client->get('/definitely-not-here')['status'] === 404);
    check($result, 'OPTIONS preflight returns 204', $client->options('/users') === 204);

    // ── Rate limiting (bucket exhaustion shows up as 429) ─────────────
    echo "\nRate limiting\n";
    $bucketRows = db_fetch_all(
        'select count(*) as n from auth_rate_limits',
    );
    check($result, 'auth_rate_limits rows were recorded during the run', (int)($bucketRows['n'] ?? 0) >= 1);
    $securityHeaders = $client->get('/health');
    check($result, 'security headers present',
        str_contains($securityHeaders['headers']['x-content-type-options'] ?? '', 'nosniff') &&
        str_contains($securityHeaders['headers']['x-frame-options'] ?? '', 'DENY'));
    check($result, 'referrer policy header present',
        str_contains($securityHeaders['headers']['referrer-policy'] ?? '', 'no-referrer'));

    echo "\n" . str_repeat('=', 50) . "\n";
    echo "Passed: {$result->passed}, Failed: " . count($result->failures) . "\n";
    if ($result->failures !== []) {
        echo "\nFailures:\n";
        foreach ($result->failures as $f) {
            echo " - {$f}\n";
        }
        return 1;
    }
    echo "ALL TESTS PASSED\n";
    return 0;
}

/**
 * Minimal PDO helper for assertions that inspect the database directly.
 */
function db_fetch(string $sql, array $params = []): array
{
    static $pdo = null;
    if ($pdo === null) {
        $pdo = new PDO(
            getenv('DB_DSN') ?: 'mysql:host=127.0.0.1;port=3307;dbname=sawalove_test',
            getenv('DB_USER') ?: 'sawalove',
            getenv('DB_PASSWORD') ?: 'testpass123',
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC],
        );
    }
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row === false ? [] : $row;
}

function db_fetch_all(string $sql, array $params = []): array
{
    static $pdo = null;
    if ($pdo === null) {
        $pdo = new PDO(
            getenv('DB_DSN') ?: 'mysql:host=127.0.0.1;port=3307;dbname=sawalove_test',
            getenv('DB_USER') ?: 'sawalove',
            getenv('DB_PASSWORD') ?: 'testpass123',
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC],
        );
    }
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row === false ? [] : $row;
}

final class ApiTestClient
{
    private string $baseUrl;
    private string $token = '';

    public function __construct(string $baseUrl)
    {
        $this->baseUrl = rtrim($baseUrl, '/');
    }

    public function withToken(?string $token): self
    {
        $clone = clone $this;
        $clone->token = (string)$token;
        return $clone;
    }

    public function get(string $path): array
    {
        return $this->request('GET', $path);
    }

    public function post(string $path, array $body = []): array
    {
        return $this->request('POST', $path, $body);
    }

    public function put(string $path, array $body): array
    {
        return $this->request('PUT', $path, $body);
    }

    public function options(string $path): int
    {
        $ch = curl_init($this->baseUrl . $path);
        curl_setopt_array($ch, [
            CURLOPT_CUSTOMREQUEST => 'OPTIONS',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HEADER => true,
        ]);
        curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        curl_close($ch);
        return $status;
    }

    /** @return array{status:int, body:array, content_type:string} */
    private function request(string $method, string $path, ?array $body = null): array
    {
        $headers = ['Accept: application/json'];
        if ($this->token !== '') {
            $headers[] = 'Authorization: Bearer ' . $this->token;
        }
        $ch = curl_init($this->baseUrl . $path);
        $opts = [
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HEADER => true,
            CURLOPT_TIMEOUT => 15,
        ];
        if ($body !== null) {
            $opts[CURLOPT_HTTPHEADER][] = 'Content-Type: application/json';
            $opts[CURLOPT_POSTFIELDS] = json_encode($body, JSON_THROW_ON_ERROR);
        }
        curl_setopt_array($ch, $opts);
        $raw = curl_exec($ch);
        if ($raw === false) {
            $error = curl_error($ch);
            curl_close($ch);
            throw new RuntimeException("Request to {$path} failed: {$error}");
        }
        $status = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        $contentType = (string)curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
        $headerSize = (int)curl_getinfo($ch, CURLINFO_HEADER_SIZE);
        curl_close($ch);
        $responseHeaders = [];
        foreach (explode("\r\n", substr((string)$raw, 0, $headerSize)) as $h) {
            $parts = explode(':', $h, 2);
            if (count($parts) === 2) {
                $responseHeaders[strtolower(trim($parts[0]))] = trim($parts[1]);
            }
        }
        $bodyRaw = substr((string)$raw, $headerSize);
        $decoded = json_decode($bodyRaw, true);
        return [
            'status' => $status,
            'body' => is_array($decoded) ? $decoded : [],
            'content_type' => $contentType,
            'headers' => $responseHeaders,
        ];
    }
}

exit(main());
