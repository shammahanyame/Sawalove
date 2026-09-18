<?php

declare(strict_types=1);

final class ApiException extends RuntimeException
{
    public function __construct(
        public int $status,
        public string $errorCode,
        string $message
    ) {
        parent::__construct($message);
    }
}

function run_app(): void
{
    load_env_file(dirname(__DIR__) . '/.env');
    configure_errors();
    send_cors_headers();

    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
        http_response_code(204);
        return;
    }

    try {
        route_request();
    } catch (ApiException $e) {
        send_json([
            'error' => [
                'code' => $e->errorCode,
                'message' => $e->getMessage(),
            ],
        ], $e->status);
    } catch (Throwable $e) {
        error_log((string)$e);
        $message = app_env() === 'production'
            ? 'Unexpected server error.'
            : $e->getMessage();
        send_json([
            'error' => [
                'code' => 'server_error',
                'message' => $message,
            ],
        ], 500);
    }
}

function route_request(): void
{
    $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    $path = request_path();        // Brute-force protection for credential endpoints (per IP).
    if (
        ($method === 'POST' && (
            $path === '/auth/email/signin' ||
            $path === '/auth/email/signup' ||
            $path === '/auth/phone/request' ||
            $path === '/auth/phone/verify'
        ))
    ) {
        assert_auth_rate_limit('ip:' . client_ip_hash() . ':' . $path);
    }

    // Always expose the standard security headers.
    send_security_headers();

    if ($method === 'GET' && $path === '/health') {
        handle_health();
        return;
    }

    if ($method === 'GET' && $path === '/auth/providers') {
        send_json([
            'providers' => auth_providers(),
        ]);
        return;
    }

    if ($method === 'POST' && $path === '/auth/phone/request') {
        handle_phone_request();
        return;
    }

    if ($method === 'POST' && $path === '/auth/phone/verify') {
        handle_phone_verify();
        return;
    }

    if ($method === 'POST' && $path === '/auth/email/signup') {
        handle_email_signup();
        return;
    }

    if ($method === 'POST' && $path === '/auth/email/signin') {
        handle_email_signin();
        return;
    }

    if ($method === 'POST' && preg_match('#^/auth/oauth/(google|apple)$#', $path, $matches)) {
        handle_oauth($matches[1]);
        return;
    }

    if ($method === 'GET' && $path === '/session') {
        handle_session();
        return;
    }

    if ($method === 'POST' && $path === '/auth/signout') {
        handle_signout();
        return;
    }

    if ($method === 'POST' && $path === '/me/pin') {
        handle_save_pin();
        return;
    }

    if ($method === 'POST' && $path === '/me/pause') {
        handle_pause_account();
        return;
    }

    if ($method === 'POST' && $path === '/me/delete-request') {
        handle_delete_request();
        return;
    }

    if ($method === 'POST' && $path === '/me/data-export') {
        handle_data_export();
        return;
    }

    if ($method === 'GET' && $path === '/users') {
        handle_list_users();
        return;
    }

    if (preg_match('#^/users/([A-Za-z0-9_-]+)$#', $path, $matches)) {
        if ($method === 'GET') {
            handle_get_user($matches[1]);
            return;
        }
        if ($method === 'PUT') {
            handle_update_user($matches[1]);
            return;
        }
    }

    if ($method === 'POST' && $path === '/photos/profile') {
        handle_profile_photo_upload();
        return;
    }

    throw new ApiException(404, 'not_found', 'Endpoint not found.');
}

function handle_health(): void
{
    pdo()->query('select 1');
    send_json([
        'ok' => true,
        'service' => 'sawalove-php-api',
        'time' => gmdate('c'),
    ]);
}

function handle_phone_request(): void
{
    if (!auth_providers()['phone']) {
        throw new ApiException(403, 'phone_provider_disabled', 'Phone sign-in is disabled.');
    }

    $body = read_json_body();
    $phone = trim((string)($body['phone'] ?? ''));
    if (!is_valid_phone($phone)) {
        throw new ApiException(422, 'invalid_phone', 'Enter a valid international phone number.');
    }

    $stmt = pdo()->prepare(
        "select count(*) from phone_otps where phone = ? and created_at >= date_sub(utc_timestamp(), interval 15 minute)"
    );
    $stmt->execute([$phone]);
    if ((int)$stmt->fetchColumn() >= 5) {
        throw new ApiException(429, 'over_request_rate_limit', 'Too many OTP requests. Try again later.');
    }

    $code = str_pad((string)random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    $expiresAt = gmdate('Y-m-d H:i:s', time() + int_env('OTP_TTL_SECONDS', 600));
    $stmt = pdo()->prepare(
        "insert into phone_otps (phone, code_hash, request_ip, expires_at) values (?, ?, ?, ?)"
    );
    $stmt->execute([
        $phone,
        otp_hash($code),
        client_ip_hash(),
        $expiresAt,
    ]);

    $smsSent = send_sms_code($phone, $code);
    // SECURITY: return the OTP in the response ONLY when explicitly enabled
    // via OTP_DEBUG_RESPONSE (local development). Never for "staging" or any
    // other environment, or the SMS code is readable by anyone with network
    // access to the API.
    $debugAllowed = bool_env('OTP_DEBUG_RESPONSE', false);
    if (!$smsSent && !$debugAllowed) {
        throw new ApiException(503, 'sms_not_configured', 'SMS delivery is not configured.');
    }

    $response = [
        'ok' => true,
        'expires_in' => int_env('OTP_TTL_SECONDS', 600),
    ];
    if ($debugAllowed) {
        $response['debug_code'] = $code;
    }

    send_json($response);
}

function handle_phone_verify(): void
{
    if (!auth_providers()['phone']) {
        throw new ApiException(403, 'phone_provider_disabled', 'Phone sign-in is disabled.');
    }

    $body = read_json_body();
    $phone = trim((string)($body['phone'] ?? ''));
    $code = trim((string)($body['code'] ?? ''));
    if (!is_valid_phone($phone) || !preg_match('/^\d{6}$/', $code)) {
        throw new ApiException(422, 'invalid_otp', 'Invalid OTP.');
    }

    $stmt = pdo()->prepare(
        "select * from phone_otps where phone = ? and consumed_at is null order by created_at desc limit 1"
    );
    $stmt->execute([$phone]);
    $otp = $stmt->fetch();
    if (!$otp || strtotime($otp['expires_at'] . ' UTC') < time()) {
        throw new ApiException(400, 'otp_expired', 'OTP expired.');
    }

    if ((int)$otp['attempts'] >= int_env('OTP_MAX_ATTEMPTS', 5)) {
        throw new ApiException(429, 'over_request_rate_limit', 'Too many OTP attempts.');
    }

    pdo()->prepare("update phone_otps set attempts = attempts + 1 where id = ?")->execute([$otp['id']]);

    if (!hash_equals((string)$otp['code_hash'], otp_hash($code))) {
        throw new ApiException(400, 'invalid_otp', 'Invalid OTP.');
    }

    pdo()->prepare("update phone_otps set consumed_at = utc_timestamp() where id = ?")->execute([$otp['id']]);
    $user = find_user_by_phone($phone) ?? create_phone_user($phone);
    assert_account_can_sign_in($user);
    $session = create_session($user['id']);

    send_json([
        'session' => $session,
        'user' => user_to_api($user),
    ]);
}

function handle_email_signup(): void
{
    if (!auth_providers()['email']) {
        throw new ApiException(403, 'email_provider_disabled', 'Email sign-in is disabled.');
    }

    $body = read_json_body();
    $name = trim((string)($body['name'] ?? ''));
    $email = normalize_email((string)($body['email'] ?? ''));
    $password = (string)($body['password'] ?? '');
    $country = strtoupper(trim((string)($body['country'] ?? '')));

    if (strlen($name) < 2 || strlen($name) > 120) {
        throw new ApiException(422, 'invalid_name', 'Name must be between 2 and 120 characters.');
    }
    if (!$email || strlen($email) > 190) {
        throw new ApiException(422, 'invalid_email', 'Enter a valid email address.');
    }
    if (strlen($password) < 8 || strlen($password) > 255) {
        throw new ApiException(422, 'weak_password', 'Password must be between 8 and 255 characters.');
    }
    if ($country !== '' && !preg_match('/^[A-Z]{2}$/', $country)) {
        throw new ApiException(422, 'invalid_country', 'Country must be a 2-letter code.');
    }

    if (find_user_by_email($email)) {
        throw new ApiException(409, 'email_already_exists', 'An account already exists for that email address.');
    }

    $id = uuid_v4();
    $stmt = pdo()->prepare(
        "insert into users (id, name, email, email_normalized, country, password_hash) values (?, ?, ?, ?, ?, ?)"
    );
    $stmt->execute([
        $id,
        $name,
        $email,
        $email,
        $country !== '' ? $country : null,
        password_hash($password, PASSWORD_DEFAULT),
    ]);

    $user = require_user_by_id($id);
    $session = create_session($id);
    send_json([
        'session' => $session,
        'user' => user_to_api($user),
    ], 201);
}

function handle_email_signin(): void
{
    if (!auth_providers()['email']) {
        throw new ApiException(403, 'email_provider_disabled', 'Email sign-in is disabled.');
    }

    $body = read_json_body();
    $email = normalize_email((string)($body['email'] ?? ''));
    $password = (string)($body['password'] ?? '');
    if (strlen($password) > 255) {
        throw new ApiException(401, 'invalid_credentials', 'The email or password is incorrect.');
    }

    $user = $email ? find_user_by_email($email) : null;
    $passwordOk = $user && $user['password_hash'] && password_verify($password, (string)$user['password_hash']);
    if (!$passwordOk) {
        // Uniform response for unknown emails and wrong passwords (no user enumeration).
        throw new ApiException(401, 'invalid_credentials', 'The email or password is incorrect.');
    }

    assert_account_can_sign_in($user);
    $session = create_session($user['id']);
    send_json([
        'session' => $session,
        'user' => user_to_api($user),
    ]);
}

function handle_oauth(string $provider): void
{
    if (!auth_providers()[$provider]) {
        throw new ApiException(403, 'provider_disabled', 'This provider is disabled.');
    }

    throw new ApiException(501, 'oauth_not_implemented', 'OAuth exchange is not implemented on this PHP backend yet.');
}

function handle_session(): void
{
    $auth = authenticate(true);
    send_json([
        'session' => session_to_api($auth['token'], $auth['session']['user_id'], $auth['session']['expires_at']),
        'user' => user_to_api($auth['user'], true),
    ]);
}

function handle_signout(): void
{
    $auth = authenticate(false);
    if ($auth) {
        pdo()->prepare("update sessions set revoked_at = utc_timestamp() where id = ?")->execute([
            $auth['session']['id'],
        ]);
    }
    send_json(['ok' => true]);
}

function handle_save_pin(): void
{
    $auth = authenticate(true);
    $body = read_json_body();

    // SECURITY: the PIN itself (4-8 digits) is sent over TLS and hashed here with
    // password_hash (bcrypt + per-user salt). Storing an unsalted client-side hash
    // would allow instant recovery of any PIN via a precomputed table of the 1M
    // possible 6-digit combinations.
    $pin = trim((string)($body['pin'] ?? ''));
    if (!preg_match('/^\d{4,8}$/', $pin)) {
        throw new ApiException(422, 'invalid_pin', 'PIN must be 4 to 8 digits.');
    }
    if (preg_match('/^(\d)\1+$/', $pin) || preg_match('/^(?:0123|1234|2345|3456|4567|5678|6789|9876|8765|7654|6543|5432|4321|3210)/', $pin)) {
        throw new ApiException(422, 'weak_pin', 'Choose a PIN that is not repeated or sequential.');
    }

    pdo()->prepare("update users set pin_hash = ? where id = ?")->execute([
        password_hash($pin, PASSWORD_DEFAULT),
        $auth['user']['id'],
    ]);
    send_json(['ok' => true]);
}

function handle_pause_account(): void
{
    $auth = authenticate(true);
    pdo()->prepare(
        "update users set status = 'paused', visible = 0, paused_at = utc_timestamp() where id = ?"
    )->execute([$auth['user']['id']]);
    send_json(['ok' => true]);
}

function handle_delete_request(): void
{
    $auth = authenticate(true);
    $deleteAfter = gmdate('Y-m-d H:i:s', time() + 30 * 24 * 60 * 60);

    pdo()->prepare(
        "update users set status = 'deletion_requested', visible = 0, deletion_requested_at = utc_timestamp(), delete_after = ? where id = ?"
    )->execute([$deleteAfter, $auth['user']['id']]);

    pdo()->prepare(
        "insert into account_deletion_requests (user_id, delete_after, status) values (?, ?, 'pending') " .
        "on duplicate key update requested_at = utc_timestamp(), delete_after = values(delete_after), status = 'pending'"
    )->execute([$auth['user']['id'], $deleteAfter]);

    send_json([
        'ok' => true,
        'delete_after' => iso_datetime($deleteAfter),
    ]);
}

function handle_data_export(): void
{
    $auth = authenticate(true);
    pdo()->prepare("insert into data_export_requests (user_id) values (?)")->execute([
        $auth['user']['id'],
    ]);
    send_json(['ok' => true], 201);
}

function handle_list_users(): void
{
    $limit = max(1, min(50, (int)($_GET['limit'] ?? 20)));
    $visibleOnly = filter_var($_GET['visible'] ?? 'true', FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
    if ($visibleOnly !== false) {
        $stmt = pdo()->prepare(
            "select * from users where visible = 1 and status = 'active' order by updated_at desc limit ?"
        );
        $stmt->bindValue(1, $limit, PDO::PARAM_INT);
        $stmt->execute();
        send_json([
            'users' => array_map('user_to_api', $stmt->fetchAll()),
        ]);
        return;
    }

    $auth = authenticate(true);
    send_json([
        'users' => [user_to_api($auth['user'], true)],
    ]);
}

function handle_get_user(string $uid): void
{
    $auth = authenticate(false);
    $user = find_user_by_id($uid);
    if (!$user) {
        throw new ApiException(404, 'user_not_found', 'User not found.');
    }

    $isOwnProfile = $auth && $auth['user']['id'] === $uid;
    if (!$isOwnProfile && (!bool_from_db($user['visible']) || $user['status'] !== 'active')) {
        throw new ApiException(404, 'user_not_found', 'User not found.');
    }

    send_json([
        'user' => user_to_api($user, $isOwnProfile),
    ]);
}

function handle_update_user(string $uid): void
{
    $auth = authenticate(true);
    if ($auth['user']['id'] !== $uid) {
        throw new ApiException(403, 'forbidden', 'You can only update your own profile.');
    }

    $body = read_json_body();
    $updates = profile_updates_from_body($body);
    if ($updates === []) {
        send_json([
            'user' => user_to_api($auth['user'], true),
        ]);
        return;
    }

    $sets = [];
    $values = [];
    foreach ($updates as $column => $value) {
        $sets[] = "$column = ?";
        $values[] = $value;
    }
    $values[] = $uid;

    pdo()->prepare("update users set " . implode(', ', $sets) . " where id = ?")->execute($values);
    send_json([
        'user' => user_to_api(require_user_by_id($uid), true),
    ]);
}

function handle_profile_photo_upload(): void
{
    $auth = authenticate(true);
    $slotIndex = (int)($_POST['slot_index'] ?? -1);
    if ($slotIndex < 0 || $slotIndex > 5) {
        throw new ApiException(422, 'invalid_slot_index', 'Photo slot index must be between 0 and 5.');
    }

    if (!isset($_FILES['photo']) || !is_array($_FILES['photo'])) {
        throw new ApiException(422, 'missing_photo', 'Photo file is required.');
    }

    $file = $_FILES['photo'];
    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
        throw new ApiException(422, 'upload_failed', 'Photo upload failed.');
    }

    $maxBytes = int_env('MAX_UPLOAD_BYTES', 5242880);
    if ((int)$file['size'] > $maxBytes) {
        throw new ApiException(413, 'file_too_large', 'Photo file is too large.');
    }

    $mimeType = detect_mime_type((string)$file['tmp_name']);
    $extensions = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
    ];
    if (!isset($extensions[$mimeType])) {
        throw new ApiException(415, 'unsupported_media_type', 'Only JPEG, PNG, and WebP photos are supported.');
    }

    $publicPath = trim(env_value('UPLOAD_PUBLIC_PATH', 'uploads/profile-photos'), "/\\");
    $publicRoot = dirname(__DIR__) . '/public/' . $publicPath;
    $userDir = $publicRoot . '/' . $auth['user']['id'];
    if (!is_dir($userDir) && !mkdir($userDir, 0755, true) && !is_dir($userDir)) {
        throw new ApiException(500, 'upload_storage_error', 'Could not create upload directory.');
    }

    // Defense in depth: if the web server is Apache, make sure uploaded files
    // can never be executed as PHP/scripts. nginx should be configured with a
    // location block that only serves static images from this path.
    ensure_uploads_htaccess($publicRoot);

    $filename = sprintf(
        'profile_%d_%d_%s.%s',
        $slotIndex,
        time(),
        bin2hex(random_bytes(4)),
        $extensions[$mimeType]
    );
    $destination = $userDir . '/' . $filename;
    if (!move_uploaded_file((string)$file['tmp_name'], $destination)) {
        throw new ApiException(500, 'upload_storage_error', 'Could not store uploaded photo.');
    }

    $relativePath = $publicPath . '/' . rawurlencode($auth['user']['id']) . '/' . rawurlencode($filename);
    $url = rtrim(public_base_url(), '/') . '/' . $relativePath;
    $storagePath = $publicPath . '/' . $auth['user']['id'] . '/' . $filename;

    pdo()->prepare(
        "insert into profile_photos (user_id, slot_index, storage_path, url) values (?, ?, ?, ?) " .
        "on duplicate key update storage_path = values(storage_path), url = values(url)"
    )->execute([$auth['user']['id'], $slotIndex, $storagePath, $url]);

    if ($slotIndex === 0 || empty($auth['user']['photo'])) {
        pdo()->prepare("update users set photo = ? where id = ?")->execute([$url, $auth['user']['id']]);
    }

    // Housekeeping: cap stored photos per user so the uploads dir cannot be
    // filled indefinitely (keeps the 2 most recent versions of each slot).
    // Delete the orphaned files first, then the rows.
    $staleStmt = pdo()->prepare(
        "select storage_path from profile_photos where user_id = ? and updated_at < (" .
        "select updated_at from (select updated_at from profile_photos where user_id = ? order by updated_at desc limit 12 offset 11) as keep)"
    );
    $staleStmt->execute([$auth['user']['id'], $auth['user']['id']]);
    $stalePaths = $staleStmt->fetchAll(PDO::FETCH_COLUMN);
    foreach ($stalePaths as $stalePath) {
        // Path is server-generated (no user input); still normalize to stay
        // inside the uploads root.
        $base = realpath(dirname(__DIR__) . '/public');
        $target = realpath(dirname(__DIR__) . '/public/' . ltrim((string)$stalePath, '/\\'));
        if ($base !== false && $target !== false && str_starts_with($target, $base . DIRECTORY_SEPARATOR)) {
            @unlink($target);
        }
    }
    if ($stalePaths !== []) {
        pdo()->prepare(
            "delete from profile_photos where user_id = ? and updated_at < (" .
            "select updated_at from (select updated_at from profile_photos where user_id = ? order by updated_at desc limit 12 offset 11) as keep)"
        )->execute([$auth['user']['id'], $auth['user']['id']]);
    }

    send_json([
        'url' => $url,
    ], 201);
}

/**
 * Standard security headers on every response.
 */
function send_security_headers(): void
{
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: no-referrer');
    header('Permissions-Policy: camera=(self), microphone=(self), geolocation=(self)');
    if (app_env() === 'production') {
        header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
    }
}

function assert_auth_rate_limit(string $bucket): void
{
    /**
     * Lightweight per-IP rate limiting for credential endpoints, backed by
     * MySQL. Uses a fixed-window counter in auth_rate_limits (see schema.sql).
     */
    $windowSeconds = int_env('AUTH_RATE_LIMIT_WINDOW', 300);
    $maxAttempts = int_env('AUTH_RATE_LIMIT_MAX', 20);
    $windowStart = gmdate('Y-m-d H:i:s', intdiv(time(), $windowSeconds) * $windowSeconds);
    $windowEnd = gmdate('Y-m-d H:i:s', intdiv(time(), $windowSeconds) * $windowSeconds + $windowSeconds);

    try {
        pdo()->prepare(
            "insert into auth_rate_limits (bucket, window_start, attempts) values (?, ?, 1) " .
            "on duplicate key update attempts = attempts + 1"
        )->execute([$bucket, $windowStart]);

        $stmt = pdo()->prepare(
            "select attempts from auth_rate_limits where bucket = ? and window_start = ?"
        );
        $stmt->execute([$bucket, $windowStart]);
        $attempts = (int)$stmt->fetchColumn();

        if ($attempts > $maxAttempts) {
            $retry = strtotime($windowEnd . ' UTC') - time();
            header('Retry-After: ' . max(1, $retry));
            throw new ApiException(429, 'over_request_rate_limit', 'Too many attempts. Try again shortly.');
        }
    } catch (ApiException $e) {
        throw $e;
    } catch (Throwable $e) {
        // Rate limiting must never take auth down; log and continue if the
        // table is missing or the DB hiccups.
        error_log('auth_rate_limit unavailable: ' . $e->getMessage());
    }
}

function client_ip_hash(): string
{
    // Do not store raw IPs; store a keyed hash (GDPR-friendly, still usable
    // as a rate-limit bucket key).
    return substr(hash_hmac('sha256', (string)($_SERVER['REMOTE_ADDR'] ?? 'unknown'), app_key()), 0, 32);
}

function ensure_uploads_htaccess(string $dir): void
{
    $marker = $dir . '/.htaccess';
    if (is_file($marker)) {
        return;
    }
    $rules = "# Uploaded images must never execute as code.\n" .
        "<FilesMatch \"\\.(php|phtml|php3|php4|php5|php7|phps|phar|pl|py|cgi|sh|asp|aspx|jsp)\$\">\n" .
        "Require all denied\n</FilesMatch>\n" .
        "php_flag engine off\n" .
        "Options -Indexes -ExecCGI\n";
    @file_put_contents($marker, $rules);
}

function auth_providers(): array
{
    return [
        'phone' => bool_env('API_PHONE_AUTH_ENABLED', true),
        'email' => bool_env('API_EMAIL_AUTH_ENABLED', true),
        'google' => bool_env('API_GOOGLE_AUTH_ENABLED', false),
        'apple' => bool_env('API_APPLE_AUTH_ENABLED', false),
    ];
}

function authenticate(bool $required): ?array
{
    $header = $_SERVER['HTTP_AUTHORIZATION']
        ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
        ?? '';
    if (!preg_match('/^Bearer\s+(.+)$/i', $header, $matches)) {
        if ($required) {
            throw new ApiException(401, 'not_authenticated', 'Authentication is required.');
        }
        return null;
    }

    $token = trim($matches[1]);
    $stmt = pdo()->prepare(
        "select sessions.id as session_id, sessions.user_id as session_user_id, " .
        "sessions.expires_at as session_expires_at, users.* from sessions " .
        "inner join users on users.id = sessions.user_id " .
        "where sessions.token_hash = ? and sessions.revoked_at is null and sessions.expires_at > utc_timestamp() " .
        "limit 1"
    );
    $stmt->execute([token_hash($token)]);
    $row = $stmt->fetch();
    if (!$row) {
        if ($required) {
            throw new ApiException(401, 'not_authenticated', 'Invalid or expired session.');
        }
        return null;
    }

    $session = [
        'id' => $row['session_id'],
        'user_id' => $row['session_user_id'],
        'expires_at' => $row['session_expires_at'],
    ];

    return [
        'token' => $token,
        'session' => $session,
        'user' => user_columns_from_join($row),
    ];
}

function create_session(string $userId): array
{
    $token = random_token();
    $expiresAt = gmdate('Y-m-d H:i:s', time() + int_env('SESSION_TTL_SECONDS', 2592000));
    pdo()->prepare(
        "insert into sessions (user_id, token_hash, expires_at) values (?, ?, ?)"
    )->execute([$userId, token_hash($token), $expiresAt]);

    return session_to_api($token, $userId, $expiresAt);
}

function session_to_api(string $token, string $userId, string $expiresAt): array
{
    return [
        'token' => $token,
        'user_id' => $userId,
        'expires_at' => iso_datetime($expiresAt),
    ];
}

function find_user_by_id(string $id): ?array
{
    $stmt = pdo()->prepare("select * from users where id = ? limit 1");
    $stmt->execute([$id]);
    $user = $stmt->fetch();
    return $user ?: null;
}

function require_user_by_id(string $id): array
{
    $user = find_user_by_id($id);
    if (!$user) {
        throw new ApiException(404, 'user_not_found', 'User not found.');
    }
    return $user;
}

function find_user_by_email(string $email): ?array
{
    $stmt = pdo()->prepare("select * from users where email_normalized = ? limit 1");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    return $user ?: null;
}

function find_user_by_phone(string $phone): ?array
{
    $stmt = pdo()->prepare("select * from users where phone = ? limit 1");
    $stmt->execute([$phone]);
    $user = $stmt->fetch();
    return $user ?: null;
}

function create_phone_user(string $phone): array
{
    $id = uuid_v4();
    $country = str_starts_with($phone, '+237') ? 'CM' : null;
    pdo()->prepare(
        "insert into users (id, phone, country) values (?, ?, ?)"
    )->execute([$id, $phone, $country]);
    return require_user_by_id($id);
}

function assert_account_can_sign_in(array $user): void
{
    if ($user['status'] === 'banned') {
        throw new ApiException(403, 'account_banned', 'This account is suspended.');
    }
    if ($user['status'] === 'deletion_requested') {
        throw new ApiException(403, 'account_deletion_requested', 'This account is scheduled for deletion.');
    }
}

function user_to_api(array $user, bool $includePrivate = false): array
{
    // SECURITY: email and phone are personal contact details. They are only
    // returned to the authenticated owner of the profile; public discovery /
    // profile responses never include them.
    $data = [
        'id' => (string)$user['id'],
        'name' => nullable_string($user['name'] ?? null),
        'country' => nullable_string($user['country'] ?? null),
        'age' => $user['age'] === null ? null : (int)$user['age'],
        'city' => (string)($user['city'] ?? 'Douala'),
        'location' => (string)($user['location'] ?? 'Cameroon'),
        'village' => (string)($user['village'] ?? 'Cameroon'),
        'goal' => (string)($user['goal'] ?? 'Connection'),
        'intent' => nullable_string($user['intent'] ?? null),
        'bio' => nullable_string($user['bio'] ?? null) ?? 'New to SawaLove.',
        'photo' => nullable_string($user['photo'] ?? null),
        'email' => $includePrivate ? nullable_string($user['email'] ?? null) : null,
        'phone' => $includePrivate ? nullable_string($user['phone'] ?? null) : null,
        'visible' => bool_from_db($user['visible'] ?? false),
        'status' => (string)($user['status'] ?? 'active'),
        'isPremium' => bool_from_db($user['is_premium'] ?? false),
        'lat' => (float)($user['lat'] ?? 0),
        'lng' => (float)($user['lng'] ?? 0),
        'distance' => (float)($user['distance'] ?? 2.5),
        'preferences' => decode_json_object($user['preferences'] ?? null),
        'created_at' => isset($user['created_at']) ? iso_datetime((string)$user['created_at']) : null,
        'updated_at' => isset($user['updated_at']) ? iso_datetime((string)$user['updated_at']) : null,
    ];

    return $data;
}

function user_columns_from_join(array $row): array
{
    return [
        'id' => $row['id'],
        'name' => $row['name'] ?? null,
        'email' => $row['email'] ?? null,
        'email_normalized' => $row['email_normalized'] ?? null,
        'phone' => $row['phone'] ?? null,
        'country' => $row['country'] ?? null,
        'password_hash' => $row['password_hash'] ?? null,
        'age' => $row['age'] ?? null,
        'city' => $row['city'] ?? 'Douala',
        'location' => $row['location'] ?? 'Cameroon',
        'village' => $row['village'] ?? 'Cameroon',
        'goal' => $row['goal'] ?? 'Connection',
        'intent' => $row['intent'] ?? null,
        'bio' => $row['bio'] ?? null,
        'photo' => $row['photo'] ?? null,
        'visible' => $row['visible'] ?? false,
        'status' => $row['status'] ?? 'active',
        'is_premium' => $row['is_premium'] ?? false,
        'lat' => $row['lat'] ?? 0,
        'lng' => $row['lng'] ?? 0,
        'distance' => $row['distance'] ?? 2.5,
        'preferences' => $row['preferences'] ?? null,
        'created_at' => $row['created_at'] ?? null,
        'updated_at' => $row['updated_at'] ?? null,
    ];
}

function profile_updates_from_body(array $body): array
{
    $updates = [];
    foreach (['name', 'country', 'city', 'location', 'village', 'goal', 'intent', 'bio', 'photo'] as $field) {
        if (array_key_exists($field, $body)) {
            $max = match ($field) {
                'bio' => 1000,
                'photo' => 512,
                'country' => 8,
                default => 190,
            };
            $updates[$field] = nullable_string($body[$field], $max);
        }
    }

    // SECURITY: the photo field is rendered as an image URL by clients. Only
    // allow http(s) URLs pointing at the configured upload host(s), so a
    // compromised account cannot plant javascript: or data: URIs, or force
    // clients to load attacker-chosen remote content. Production requires
    // https; local development may use the API's own http host.
    if (array_key_exists('photo', $updates) && $updates['photo'] !== null) {
        $photo = $updates['photo'];
        $parsed = parse_url($photo);
        $scheme = strtolower((string)($parsed['scheme'] ?? ''));
        $allowedHosts = array_filter(array_map(
            static fn (string $host): string => strtolower(parse_url($host, PHP_URL_HOST) ?: $host),
            array_map('trim', explode(',', env_value('UPLOAD_ALLOWED_HOSTS', '')))
        ));
        $selfHost = strtolower((string)parse_url(public_base_url(), PHP_URL_HOST));
        $selfScheme = strtolower((string)parse_url(public_base_url(), PHP_URL_SCHEME));
        $isSelfUrl = $selfHost !== ''
            && strtolower((string)($parsed['host'] ?? '')) === $selfHost
            && $scheme === $selfScheme;
        if (!in_array($scheme, ['http', 'https'], true) || ($parsed['host'] ?? '') === '') {
            throw new ApiException(422, 'invalid_photo_url', 'Photo must be an http(s) URL.');
        }
        if (app_env() === 'production' && $scheme !== 'https') {
            throw new ApiException(422, 'invalid_photo_url', 'Photo must use https.');
        }
        if (
            !$isSelfUrl &&
            !in_array(strtolower((string)$parsed['host']), $allowedHosts, true)
        ) {
            throw new ApiException(422, 'invalid_photo_url', 'Photo must be hosted on an allowed host.');
        }
    }

    if (array_key_exists('age', $body)) {
        $age = $body['age'] === null ? null : (int)$body['age'];
        if ($age !== null && ($age < 18 || $age > 100)) {
            throw new ApiException(422, 'invalid_age', 'Age must be between 18 and 100.');
        }
        $updates['age'] = $age;
    }

    if (array_key_exists('visible', $body)) {
        $updates['visible'] = truthy($body['visible']) ? 1 : 0;
        if ($updates['visible'] === 1) {
            $updates['status'] = 'active';
            $updates['paused_at'] = null;
        }
    }

    foreach (['lat', 'lng', 'distance'] as $field) {
        if (array_key_exists($field, $body)) {
            $value = filter_var(
                $body[$field],
                FILTER_VALIDATE_FLOAT,
                ['options' => ['default' => null]]
            );
            if ($value === null) {
                throw new ApiException(422, 'invalid_' . $field, ucfirst($field) . ' must be a number.');
            }
            if ($field === 'lat' && ($value < -90 || $value > 90)) {
                throw new ApiException(422, 'invalid_lat', 'Latitude must be between -90 and 90.');
            }
            if ($field === 'lng' && ($value < -180 || $value > 180)) {
                throw new ApiException(422, 'invalid_lng', 'Longitude must be between -180 and 180.');
            }
            if ($field === 'distance' && ($value < 0 || $value > 5000)) {
                throw new ApiException(422, 'invalid_distance', 'Distance must be between 0 and 5000.');
            }
            $updates[$field] = (float)$value;
        }
    }

    if (array_key_exists('preferences', $body)) {
        $updates['preferences'] = json_encode(
            is_array($body['preferences']) ? $body['preferences'] : [],
            JSON_THROW_ON_ERROR
        );
    }

    return $updates;
}

function read_json_body(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
        return [];
    }

    try {
        $decoded = json_decode($raw, true, flags: JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        throw new ApiException(400, 'invalid_json', 'Request body must be valid JSON.');
    }

    if (!is_array($decoded)) {
        throw new ApiException(400, 'invalid_json', 'Request body must be a JSON object.');
    }

    return $decoded;
}

function send_json(array $data, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
}

function pdo(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $dsn = env_value('DB_DSN');
    if ($dsn === '') {
        throw new ApiException(500, 'config_error', 'DB_DSN is not configured.');
    }

    $pdo = new PDO($dsn, env_value('DB_USER'), env_value('DB_PASSWORD'), [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    $pdo->exec("set time_zone = '+00:00'");
    return $pdo;
}

function send_sms_code(string $phone, string $code): bool
{
    $url = env_value('SMS_HTTP_URL');
    if ($url === '' || !function_exists('curl_init')) {
        return false;
    }

    $message = "Your SawaLove OTP is $code. It expires in 10 minutes.";
    $payload = json_encode([
        'to' => $phone,
        'message' => $message,
    ], JSON_THROW_ON_ERROR);

    $headers = ['Content-Type: application/json'];
    $authHeader = env_value('SMS_HTTP_AUTH_HEADER');
    if ($authHeader !== '') {
        $headers[] = $authHeader;
    }

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $payload,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 10,
    ]);
    $result = curl_exec($ch);
    $status = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);

    return $result !== false && $status >= 200 && $status < 300;
}

function detect_mime_type(string $path): string
{
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    if ($finfo === false) {
        return 'application/octet-stream';
    }
    $mime = finfo_file($finfo, $path);
    finfo_close($finfo);
    return is_string($mime) ? $mime : 'application/octet-stream';
}

function normalize_email(string $email): ?string
{
    $email = strtolower(trim($email));
    return filter_var($email, FILTER_VALIDATE_EMAIL) ? $email : null;
}

function is_valid_phone(string $phone): bool
{
    return (bool)preg_match('/^\+[1-9]\d{7,14}$/', $phone);
}

function random_token(): string
{
    return rtrim(strtr(base64_encode(random_bytes(32)), '+/', '-_'), '=');
}

function token_hash(string $token): string
{
    return hash_hmac('sha256', $token, app_key());
}

function otp_hash(string $code): string
{
    return hash_hmac('sha256', $code, app_key());
}

function app_key(): string
{
    $key = env_value('APP_KEY');
    if ($key !== '') {
        return $key;
    }
    if (app_env() === 'production') {
        throw new ApiException(500, 'config_error', 'APP_KEY is not configured.');
    }
    return 'local-development-key';
}

function uuid_v4(): string
{
    $data = random_bytes(16);
    $data[6] = chr((ord($data[6]) & 0x0f) | 0x40);
    $data[8] = chr((ord($data[8]) & 0x3f) | 0x80);
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

function bool_from_db(mixed $value): bool
{
    return (bool)(int)$value;
}

function truthy(mixed $value): bool
{
    return filter_var($value, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?? false;
}

function nullable_string(mixed $value, int $max = 512): ?string
{
    if ($value === null) {
        return null;
    }
    $text = trim((string)$value);
    if ($text === '') {
        return null;
    }
    return function_exists('mb_substr') ? mb_substr($text, 0, $max) : substr($text, 0, $max);
}

function decode_json_object(mixed $json): array
{
    if (!is_string($json) || trim($json) === '') {
        return [];
    }
    try {
        $decoded = json_decode($json, true, flags: JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        return [];
    }
    return is_array($decoded) ? $decoded : [];
}

function iso_datetime(string $mysqlDate): string
{
    $timestamp = strtotime($mysqlDate . ' UTC');
    return gmdate('c', $timestamp === false ? time() : $timestamp);
}

function request_path(): string
{
    $pathInfo = $_SERVER['PATH_INFO'] ?? '';
    if ($pathInfo !== '') {
        return normalize_path($pathInfo);
    }

    $uriPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
    $scriptName = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '');
    if ($scriptName !== '' && starts_with($uriPath, $scriptName)) {
        return normalize_path(substr($uriPath, strlen($scriptName)));
    }

    $scriptDir = rtrim(str_replace('\\', '/', dirname($scriptName)), '/');
    if ($scriptDir !== '' && $scriptDir !== '.' && $scriptDir !== '/' && starts_with($uriPath, $scriptDir)) {
        return normalize_path(substr($uriPath, strlen($scriptDir)));
    }

    return normalize_path($uriPath);
}

function normalize_path(string $path): string
{
    $path = '/' . trim($path, '/');
    return $path === '/' ? '/' : $path;
}

function starts_with(string $haystack, string $needle): bool
{
    return $needle === '' || strncmp($haystack, $needle, strlen($needle)) === 0;
}

function public_base_url(): string
{
    $configured = env_value('APP_URL');
    if ($configured !== '') {
        return $configured;
    }

    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    $scriptDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
    return $scheme . '://' . $host . ($scriptDir && $scriptDir !== '/' ? $scriptDir : '');
}

function configure_errors(): void
{
    ini_set('display_errors', app_env() === 'production' ? '0' : '1');
    error_reporting(E_ALL);
}

function send_cors_headers(): void
{
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $allowed = array_filter(array_map('trim', explode(',', env_value('CORS_ALLOWED_ORIGINS', '*'))));
    if (in_array('*', $allowed, true)) {
        header('Access-Control-Allow-Origin: *');
    } elseif ($origin !== '' && in_array($origin, $allowed, true)) {
        header('Access-Control-Allow-Origin: ' . $origin);
        header('Vary: Origin');
    }

    header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
    header('Access-Control-Allow-Headers: Authorization, Content-Type, Accept');
}

function load_env_file(string $path): void
{
    if (!is_file($path)) {
        return;
    }

    foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [] as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) {
            continue;
        }
        [$name, $value] = array_map('trim', explode('=', $line, 2));
        if ($name === '' || getenv($name) !== false) {
            continue;
        }
        if (
            (str_starts_with($value, '"') && str_ends_with($value, '"')) ||
            (str_starts_with($value, "'") && str_ends_with($value, "'"))
        ) {
            $value = substr($value, 1, -1);
        }
        $_ENV[$name] = $value;
        putenv("$name=$value");
    }
}

function env_value(string $name, string $default = ''): string
{
    $value = getenv($name);
    if ($value === false && array_key_exists($name, $_ENV)) {
        $value = $_ENV[$name];
    }
    if ($value === false && array_key_exists($name, $_SERVER)) {
        $value = $_SERVER[$name];
    }
    return $value === false ? $default : (string)$value;
}

function app_env(): string
{
    return strtolower(env_value('APP_ENV', 'production'));
}

function bool_env(string $name, bool $default): bool
{
    $value = env_value($name);
    if ($value === '') {
        return $default;
    }
    return truthy($value);
}

function int_env(string $name, int $default): int
{
    $value = env_value($name);
    if ($value === '' || !is_numeric($value)) {
        return $default;
    }
    return (int)$value;
}
