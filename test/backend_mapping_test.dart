import 'package:flutter_test/flutter_test.dart';
import 'package:sawalove/shared/services/backend_service.dart';

void main() {
  group('BackendService.normalizeMatches', () {
    // The mapping helpers were removed from the class; the mapping now
    // happens server-side (the RPC returns the flat wire format the inbox
    // reads). Kept to document the expected shape of `fetch_matches` rows.
    test('flattens the peer and exposes the fields the inbox reads', () {
      final matches = BackendService.normalizeMatches([
        {
          'match_id': 'match-1',
          'created_at': '2026-10-01T09:00:00Z',
          'peer': {
            'id': 'peer-1',
            'name': 'Amaka',
            'photo': 'https://example.com/a.jpg',
          },
          'last_message': 'hello there',
        },
      ]);

      expect(matches, hasLength(1));
      final match = matches.single;
      expect(match['id'], 'match-1');
      expect(match['match_id'], 'match-1');
      expect(match['matchedAt'], '2026-10-01T09:00:00Z');
      expect(match['name'], 'Amaka');
      expect(match['user'], isA<Map<String, dynamic>>());
      expect((match['user'] as Map)['id'], 'peer-1');
      expect((match['user'] as Map)['photo'], 'https://example.com/a.jpg');
      expect(match['lastMessage'], {
        'body': 'hello there',
        'at': '2026-10-01T09:00:00Z',
      });
      expect(match['last_message'], 'hello there');
    });

    test('accepts an object last_message and a missing peer', () {
      final matches = BackendService.normalizeMatches([
        {
          'match_id': 'match-2',
          'last_message': {'body_preview': 'see you'},
        },
      ]);

      final match = matches.single;
      expect(match['user'], isEmpty);
      expect((match['lastMessage'] as Map)['body'], 'see you');
    });

    test('leaves lastMessage null when the match has no messages', () {
      final match = BackendService.normalizeMatches([
        {'match_id': 'match-3', 'peer': {'name': 'Bih'}},
      ]).single;

      expect(match['lastMessage'], isNull);
      expect(match.containsKey('last_message'), isFalse);
    });
  });

  group('BackendService.normalizeMessages', () {
    test('restores chronological order and flags my messages', () {
      final messages = BackendService.normalizeMessages(
        [
          // Server returns newest first.
          {
            'id': 3,
            'match_id': 'match-1',
            'sender_id': 'me',
            'body': 'third',
            'created_at': '2026-10-01T09:02:00Z',
          },
          {
            'id': 2,
            'match_id': 'match-1',
            'sender_id': 'peer',
            'body': 'second',
            'created_at': '2026-10-01T09:01:00Z',
          },
          {
            'id': 1,
            'match_id': 'match-1',
            'sender_id': 'me',
            'body': 'first',
            'created_at': '2026-10-01T09:00:00Z',
          },
        ],
        currentUserId: 'me',
      );

      expect(messages.map((m) => m['body']), ['first', 'second', 'third']);
      expect(messages.map((m) => m['fromMe']), [true, false, true]);
      expect(messages.first['senderId'], 'me');
      expect(messages.first['createdAt'], '2026-10-01T09:00:00Z');
    });

    test('treats every message as incoming when there is no signed-in user',
        () {
      final messages = BackendService.normalizeMessages([
        {'id': 1, 'sender_id': 'peer', 'body': 'hi'},
      ]);

      expect(messages.single['fromMe'], isFalse);
    });
  });
}
