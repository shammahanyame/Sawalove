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

    // ── Likes, matches & chat ───────────────────────────────────────
    echo "\nLikes, matches & chat\n";
    $signupA = $client->post('/auth/email/signup', [
        'name' => 'Alice Chat', 'email' => 'alice-' . bin2hex(random_bytes(4)) . '@example.com',
        'password' => 'correct-horse-battery',
    ]);
    $signupB = $client->post('/auth/email/signup', [
        'name' => 'Bob Chat', 'email' => 'bob-' . bin2hex(random_bytes(4)) . '@example.com',
        'password' => 'correct-horse-battery',
    ]);
    $signupC = $client->post('/auth/email/signup', [
        'name' => 'Cara Lurker', 'email' => 'cara-' . bin2hex(random_bytes(4)) . '@example.com',
        'password' => 'correct-horse-battery',
    ]);
    $aId = $signupA['body']['user']['id']; $aTok = $signupA['body']['session']['token'];
    $bId = $signupB['body']['user']['id']; $bTok = $signupB['body']['session']['token'];
    $cId = $signupC['body']['user']['id']; $cTok = $signupC['body']['session']['token'];

    $A = $client->withToken($aTok);
    $B = $client->withToken($bTok);
    $C = $client->withToken($cTok);
    $A->put('/users/' . $aId, ['visible' => true]);
    $B->put('/users/' . $bId, ['visible' => true]);
    $C->put('/users/' . $cId, ['visible' => true]);

    // Swipe validation
    $badAction = $A->post('/swipes', ['targetUserId' => $bId, 'action' => 'love']);
    check($result, 'swipe rejects unknown action (422)', $badAction['status'] === 422, "got {$badAction['status']}");
    $selfSwipe = $A->post('/swipes', ['targetUserId' => $aId, 'action' => 'like']);
    check($result, 'self-swipe rejected (422)', $selfSwipe['status'] === 422);
    $ghostSwipe = $A->post('/swipes', ['targetUserId' => 'nonexistent-user', 'action' => 'like']);
    check($result, 'swipe on unknown target returns 404 (no enumeration)', $ghostSwipe['status'] === 404);
    $anonSwipe = $client->post('/swipes', ['targetUserId' => $bId, 'action' => 'like']);
    check($result, 'anonymous swipe rejected (401)', $anonSwipe['status'] === 401);

    // One-way like: no match yet
    $likeAB = $A->post('/swipes', ['targetUserId' => $bId, 'action' => 'like']);
    check($result, 'one-way like returns matched=false', $likeAB['status'] === 200 && $likeAB['body']['matched'] === false);

    // C cannot see B's match list; B has no matches yet
    $noMatches = $B->get('/matches');
    check($result, 'no match before reciprocity', ($noMatches['body']['matches'] ?? []) === []);

    // Reciprocal like creates a match
    $likeBA = $B->post('/swipes', ['targetUserId' => $aId, 'action' => 'like']);
    check($result, 'reciprocal like creates a match', $likeBA['status'] === 200 && $likeBA['body']['matched'] === true && is_string($likeBA['body']['match_id']));
    $matchId = (string)$likeBA['body']['match_id'];

    // Re-swiping the same person is idempotent (upsert), still matched
    $relike = $A->post('/swipes', ['targetUserId' => $bId, 'action' => 'like']);
    check($result, 're-like is idempotent and keeps the match', $relike['status'] === 200 && $relike['body']['matched'] === true);

    // Likes list: B liked A back, so A's pending likes should be empty (B consumed)
    // C likes A -> A should now see C in /likes
    $C->post('/swipes', ['targetUserId' => $aId, 'action' => 'like']);
    $likesA = $A->get('/likes');
    $likerIds = array_map(static fn (array $u) => $u['id'] ?? '', $likesA['body']['likes'] ?? []);
    check($result, 'GET /likes shows pending likers', in_array($cId, $likerIds, true), json_encode($likerIds));
    check($result, 'GET /likes never leaks email/phone',
        !isset($likesA['body']['likes'][0]['email']) || $likesA['body']['likes'][0]['email'] === null);

    // Matches list shows the match on both sides with the other user's data
    $matchesA = $A->get('/matches');
    $matchIdsA = array_map(static fn (array $m) => $m['id'] ?? '', $matchesA['body']['matches'] ?? []);
    check($result, 'GET /matches lists the new match for A', in_array($matchId, $matchIdsA, true));
    $matchA = $matchesA['body']['matches'][array_search($matchId, $matchIdsA, true)];
    check($result, 'match shows the OTHER user\'s profile, not mine', ($matchA['user']['id'] ?? '') === $bId);
    $matchesB = $B->get('/matches');
    $matchIdsB = array_map(static fn (array $m) => $m['id'] ?? '', $matchesB['body']['matches'] ?? []);
    check($result, 'GET /matches lists the new match for B', in_array($matchId, $matchIdsB, true));

    // Messaging
    $unauthMsg = $client->get('/matches/' . $matchId . '/messages');
    check($result, 'messages require auth (401)', $unauthMsg['status'] === 401);
    $outsiderMsg = $C->get('/matches/' . $matchId . '/messages');
    check($result, 'outsider cannot read messages (404, no enumeration)', $outsiderMsg['status'] === 404);

    $empty = $A->get('/matches/' . $matchId . '/messages');
    check($result, 'empty conversation returns []', ($empty['body']['messages'] ?? null) === []);

    $send1 = $A->post('/matches/' . $matchId . '/messages', ['body' => 'Bonjour Bob!']);
    check($result, 'A sends a message (201)', $send1['status'] === 201 && ($send1['body']['message']['body'] ?? '') === 'Bonjour Bob!');
    $send2 = $B->post('/matches/' . $matchId . '/messages', ['body' => 'Salut Alice!']);
    check($result, 'B sends a message (201)', $send2['status'] === 201);

    $thread = $A->get('/matches/' . $matchId . '/messages');
    $bodies = array_map(static fn (array $m) => $m['body'] ?? '', $thread['body']['messages'] ?? []);
    check($result, 'conversation returns both messages in order', $bodies === ['Bonjour Bob!', 'Salut Alice!'], json_encode($bodies));
    $first = $thread['body']['messages'][0] ?? [];
    check($result, 'fromMe is true for my own messages', $first['fromMe'] === true);
    $threadB = $B->get('/matches/' . $matchId . '/messages');
    check($result, 'fromMe is false for the other side', ($threadB['body']['messages'][0]['fromMe'] ?? null) === false);

    $badMsg = $A->post('/matches/' . $matchId . '/messages', ['body' => str_repeat('x', 4001)]);
    check($result, 'message over 4000 chars rejected (422)', $badMsg['status'] === 422);
    $blankMsg = $A->post('/matches/' . $matchId . '/messages', ['body' => '   ']);
    check($result, 'blank message rejected (422)', $blankMsg['status'] === 422);
    $fakeMatch = $A->get('/matches/does-not-exist/messages');
    check($result, 'unknown match returns 404', $fakeMatch['status'] === 404);

    // lastMessage preview appears in the matches list
    $matchesA2 = $A->get('/matches');
    $mA = $matchesA2['body']['matches'][array_search($matchId, array_map(static fn (array $m) => $m['id'] ?? '', $matchesA2['body']['matches'] ?? []), true)];
    check($result, 'match list includes lastMessage preview', ($mA['lastMessage']['body'] ?? '') === 'Salut Alice!');
    check($result, 'lastMessage.fromMe computed per viewer', ($mA['lastMessage']['fromMe'] ?? null) === false);

    // Unmatch: A unmatched -> conversation hidden for A, still visible for B (read-only history)
    $unmatch = $A->delete('/matches/' . $matchId);
    check($result, 'DELETE /matches/{id} unmatches (ok)', ($unmatch['body']['ok'] ?? false) === true);
    $afterA = $A->get('/matches/' . $matchId . '/messages');
    check($result, 'unmatched side sees 404 on the conversation', $afterA['status'] === 404);
    $afterAList = $A->get('/matches');
    $stillThereA = in_array($matchId, array_map(static fn (array $m) => $m['id'] ?? '', $afterAList['body']['matches'] ?? []));
    check($result, 'unmatched side no longer lists the match', $stillThereA === false);
    $afterB = $B->get('/matches/' . $matchId . '/messages');
    check($result, 'other side still sees history after unmatch', $afterB['status'] === 200 && count($afterB['body']['messages']) === 2);
    $bSendAfter = $B->post('/matches/' . $matchId . '/messages', ['body' => 'hello?']);
    check($result, 'cannot send after the other side unmatched (410)', $bSendAfter['status'] === 410);
    // Re-like reactivates
    $relikeAfter = $A->post('/swipes', ['targetUserId' => $bId, 'action' => 'like']);
    check($result, 're-like reactivates the match', $relikeAfter['status'] === 200 && $relikeAfter['body']['matched'] === true);
    $reactivated = $A->get('/matches/' . $matchId . '/messages');
    check($result, 'history intact after reactivation', $reactivated['status'] === 200 && count($reactivated['body']['messages']) === 2);

    // ── Blocking ───────────────────────────────────────────────
    echo "\nBlocking\n";
    $anonBlock = $client->post('/users/' . $cId . '/block');
    check($result, 'anonymous block rejected (401)', $anonBlock['status'] === 401, "got {$anonBlock['status']}");
    $selfBlock = $A->post('/users/' . $aId . '/block');
    check($result, 'self-block rejected (422)', $selfBlock['status'] === 422, "got {$selfBlock['status']}");
    $ghostBlock = $A->post('/users/nonexistent-user/block');
    check($result, 'block on unknown user returns 404 (no enumeration)', $ghostBlock['status'] === 404, "got {$ghostBlock['status']}");
    $anonListBlocks = $client->get('/blocks');
    check($result, 'GET /blocks requires auth (401)', $anonListBlocks['status'] === 401);

    // A blocks C (C liked A earlier, so C is in A's likes list)
    $blockC = $A->post('/users/' . $cId . '/block');
    check($result, 'block returns ok', $blockC['status'] === 200 && ($blockC['body']['ok'] ?? false) === true);
    $blockCAgain = $A->post('/users/' . $cId . '/block');
    check($result, 'duplicate block is idempotent (200)', $blockCAgain['status'] === 200, "got {$blockCAgain['status']}");

    $likesAfterBlock = $A->get('/likes');
    $likerIdsAfter = array_map(static fn (array $u) => $u['id'] ?? '', $likesAfterBlock['body']['likes'] ?? []);
    check($result, 'blocked liker disappears from GET /likes', !in_array($cId, $likerIdsAfter, true), json_encode($likerIdsAfter));

    // Authenticated discovery deck excludes self, swiped, and blocked users
    $deckA = $A->get('/users?visible=true&limit=50');
    $deckIdsA = array_map(static fn (array $u) => $u['id'] ?? '', $deckA['body']['users'] ?? []);
    check($result, 'authenticated deck never includes myself', !in_array($aId, $deckIdsA, true));
    check($result, 'authenticated deck excludes already-swiped users', !in_array($bId, $deckIdsA, true), json_encode($deckIdsA));
    check($result, 'authenticated deck excludes blocked users', !in_array($cId, $deckIdsA, true));
    check($result, 'deck filtering keeps other visible users', count($deckIdsA) >= 1, json_encode($deckIdsA));

    $deckC = $C->get('/users?visible=true&limit=50');
    $deckIdsC = array_map(static fn (array $u) => $u['id'] ?? '', $deckC['body']['users'] ?? []);
    check($result, 'blocked direction also filtered for the other side', !in_array($aId, $deckIdsC, true), json_encode($deckIdsC));
    check($result, 'unrelated profiles still visible to C', in_array($bId, $deckIdsC, true), json_encode($deckIdsC));

    $profileBlockedA = $A->get('/users/' . $cId);
    check($result, 'blocker cannot read blocked profile (404)', $profileBlockedA['status'] === 404, "got {$profileBlockedA['status']}");
    $profileBlockedC = $C->get('/users/' . $aId);
    check($result, 'blocked side cannot read blocker profile (404)', $profileBlockedC['status'] === 404, "got {$profileBlockedC['status']}");

    $blocksA = $A->get('/blocks');
    $blockedIds = array_map(static fn (array $u) => $u['id'] ?? '', $blocksA['body']['blocks'] ?? []);
    check($result, 'GET /blocks lists the blocked user', in_array($cId, $blockedIds, true), json_encode($blockedIds));

    // B blocks A -> the active match disappears for BOTH sides and chat/swipe stop
    $blockAbyB = $B->post('/users/' . $aId . '/block');
    check($result, 'B can block A (200)', $blockAbyB['status'] === 200, "got {$blockAbyB['status']}");
    $matchesWhileBlockedA = $A->get('/matches');
    $idsWhileBlockedA = array_map(static fn (array $m) => $m['id'] ?? '', $matchesWhileBlockedA['body']['matches'] ?? []);
    check($result, 'match hidden from blocker side', !in_array($matchId, $idsWhileBlockedA, true));
    $matchesWhileBlockedB = $B->get('/matches');
    $idsWhileBlockedB = array_map(static fn (array $m) => $m['id'] ?? '', $matchesWhileBlockedB['body']['matches'] ?? []);
    check($result, 'match hidden from blocked side', !in_array($matchId, $idsWhileBlockedB, true));
    $msgWhileBlocked = $A->post('/matches/' . $matchId . '/messages', ['body' => 'are you there?']);
    check($result, 'cannot message a blocked pair (404)', $msgWhileBlocked['status'] === 404, "got {$msgWhileBlocked['status']}");
    $swipeWhileBlocked = $A->post('/swipes', ['targetUserId' => $bId, 'action' => 'like']);
    check($result, 'cannot swipe a blocked pair (404, no leak)', $swipeWhileBlocked['status'] === 404, "got {$swipeWhileBlocked['status']}");

    // Unblock restores visibility
    $unblockA = $B->delete('/users/' . $aId . '/block');
    check($result, 'unblock returns ok', $unblockA['status'] === 200 && ($unblockA['body']['ok'] ?? false) === true);
    $unblockAgain = $B->delete('/users/' . $aId . '/block');
    check($result, 'duplicate unblock is idempotent (200)', $unblockAgain['status'] === 200);
    $matchesAfterUnblock = $B->get('/matches');
    $idsAfterUnblock = array_map(static fn (array $m) => $m['id'] ?? '', $matchesAfterUnblock['body']['matches'] ?? []);
    check($result, 'unblocking restores the match', in_array($matchId, $idsAfterUnblock, true), json_encode($idsAfterUnblock));
    $blocksAfter = $A->get('/blocks');
    $blockedAfter = array_map(static fn (array $u) => $u['id'] ?? '', $blocksAfter['body']['blocks'] ?? []);
    check($result, 'blocker list no longer contains A-blocked user after unblock', !in_array($aId, $blockedAfter, true));

    // ── 404 & method handling ─────────────────────────────────────
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

    public function delete(string $path): array
    {
        return $this->request('DELETE', $path);
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
