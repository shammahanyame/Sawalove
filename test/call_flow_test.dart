import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sawalove/features/chat/models/incoming_call_data.dart';
import 'package:sawalove/features/chat/providers/video_call_provider.dart';
import 'package:sawalove/shared/services/backend_service.dart';
import 'package:sawalove/shared/services/push_service.dart';

void main() {
  group('PushService.incomingCallPayload', () {
    test('turns an FCM data payload into the extras the call screen reads', () {
      final call = PushService.incomingCallPayload({
        'type': 'incoming_call',
        'callId': 'call-1',
        'callerId': 'peer-1',
        'callerName': 'Amaka',
        'callerAvatar': 'https://example.com/a.jpg',
        'matchId': 'match-1',
        'faith': 'Presbyterian',
        'superLikedYou': 'true',
        'isVerified': 'false',
      });

      expect(call, isNotNull);
      expect(call!['callId'], 'call-1');
      expect(call['callerId'], 'peer-1');
      expect(call['callerName'], 'Amaka');
      expect(call['matchId'], 'match-1');
      expect(call['faith'], 'Presbyterian');
      expect(call['superLikedYou'], isTrue);
      expect(call['isVerified'], isFalse);
    });

    test('defaults a missing caller name instead of ringing an empty title', () {
      final call = PushService.incomingCallPayload({
        'type': 'incoming_call',
        'callId': 'call-2',
      });

      expect(call!['callerName'], 'Someone');
      expect(call['callerAvatar'], '');
    });

    test('ignores other message types and calls without an id', () {
      expect(
        PushService.incomingCallPayload({'type': 'chat', 'callId': 'call-3'}),
        isNull,
      );
      expect(
        PushService.incomingCallPayload({'type': 'incoming_call'}),
        isNull,
      );
    });
  });

  group('IncomingCallData', () {
    test('round-trips the push payload and keeps the call id', () {
      final data = IncomingCallData.fromMap({
        'callerId': 'peer-1',
        'callerName': 'Amaka',
        'matchId': 'match-1',
        'callId': 'call-1',
        'faith': 'Presbyterian',
        'superLikedYou': true,
        'isVerified': true,
      });

      expect(data.callId, 'call-1');
      expect(data.toMap()['callId'], 'call-1');
      expect(data.superLikedYou, isTrue);

      final renamed = data.copyWith(callerName: 'Bih');
      expect(renamed.callerName, 'Bih');
      // The call id survives edits, so accepting still joins the right call.
      expect(renamed.callId, 'call-1');
    });
  });

  group('BackendService.normalizeIncomingRing (polling fallback)', () {
    test('rings a call row with the caller profile attached', () {
      final ring = BackendService.normalizeIncomingRing(
        {
          'id': 'call-1',
          'match_id': 'match-1',
          'caller_id': 'peer-1',
          'callee_id': 'me',
          'status': 'ringing',
        },
        {
          'id': 'peer-1',
          'name': 'Amaka',
          'photo': 'https://example.com/a.jpg',
          'faith': 'Presbyterian',
        },
      );

      expect(ring!['callId'], 'call-1');
      expect(ring['callerId'], 'peer-1');
      expect(ring['callerName'], 'Amaka');
      expect(ring['callerAvatar'], 'https://example.com/a.jpg');
      expect(ring['matchId'], 'match-1');
      expect(ring['faith'], 'Presbyterian');
    });

    test('still rings when the caller profile is unreadable', () {
      final ring = BackendService.normalizeIncomingRing({
        'id': 'call-2',
        'match_id': 'match-1',
        'caller_id': 'peer-1',
      });

      expect(ring!['callerName'], 'Someone');
      expect(ring['callerAvatar'], '');
      expect(ring['superLikedYou'], isFalse);
    });

    test('refuses rows that cannot open the call screen', () {
      expect(BackendService.normalizeIncomingRing({}), isNull);
      expect(
        BackendService.normalizeIncomingRing({'id': 'call-3'}),
        isNull,
      );
    });

    test('uses the same keys as the push payload', () {
      // One screen serves both paths, so the shapes must not drift apart.
      final polled = BackendService.normalizeIncomingRing(
        {'id': 'call-1', 'caller_id': 'peer-1', 'match_id': 'match-1'},
        {'id': 'peer-1', 'name': 'Amaka'},
      )!;
      final pushed = PushService.incomingCallPayload({
        'type': 'incoming_call',
        'callId': 'call-1',
        'callerId': 'peer-1',
        'matchId': 'match-1',
      })!;

      expect(polled.keys.toSet(), pushed.keys.toSet());
    });
  });

  group('Push token registration', () {
    test('stores the token against the signed-in user', () {
      final row = BackendService.pushTokenRow(
        token: 'fcm-token-1',
        userId: 'me',
        seenAt: DateTime.utc(2026, 10, 1, 9, 30),
      );

      expect(row['token'], 'fcm-token-1');
      expect(row['user_id'], 'me');
      // Android is the default because that is what most builds run on.
      expect(row['platform'], 'android');
      expect(row['last_seen_at'], '2026-10-01T09:30:00.000Z');
    });

    test('records the platform so a stale iOS token can be pruned', () {
      expect(
        BackendService.pushTokenRow(
          token: 't',
          userId: 'me',
          platform: 'ios',
        )['platform'],
        'ios',
      );
    });

    test('maps the target platform of this build', () {
      expect(
        PushService.platformFor(TargetPlatform.android),
        'android',
      );
      expect(PushService.platformFor(TargetPlatform.iOS), 'ios');
      expect(PushService.platformFor(TargetPlatform.macOS), 'ios');
      expect(
        PushService.platformFor(TargetPlatform.iOS, web: true),
        'web',
      );
    });
  });

  group('VideoCallParams', () {
    test('treats the same call as one provider instance', () {
      expect(
        VideoCallParams(matchId: 'match-1', callId: 'call-1'),
        VideoCallParams(matchId: 'match-1', callId: 'call-1'),
      );
      expect(
        VideoCallParams(matchId: 'match-1', callId: 'call-1'),
        isNot(VideoCallParams(matchId: 'match-1', callId: 'call-2')),
      );
    });

    test('distinguishes the caller from the callee of the same match', () {
      // A caller has no call id yet; the callee answers with one.
      expect(
        VideoCallParams(matchId: 'match-1'),
        isNot(VideoCallParams(matchId: 'match-1', callId: 'call-1')),
      );
      expect(
        VideoCallParams(matchId: 'match-1').hashCode,
        isNot(VideoCallParams(matchId: 'match-1', callId: 'call-1').hashCode),
      );
    });
  });

  group('VideoCallState', () {
    test('formats the call duration', () {
      expect(VideoCallState().formattedDuration, '00:00');
      expect(VideoCallState(callSeconds: 65).formattedDuration, '01:05');
      expect(VideoCallState(callSeconds: 3600).formattedDuration, '60:00');
    });

    test('copyWith keeps the peer name and updates the duration', () {
      final state = VideoCallState(remoteName: 'Amaka').copyWith(callSeconds: 3);

      expect(state.remoteName, 'Amaka');
      expect(state.formattedDuration, '00:03');
      expect(state.state, CallState.connecting);
    });
  });

  group('BackendService.normalizeCallHistory', () {
    test('marks outgoing completed calls and measures the duration', () {
      final calls = BackendService.normalizeCallHistory(
        [
          {
            'id': 'call-1',
            'match_id': 'match-1',
            'caller_id': 'me',
            'callee_id': 'peer-1',
            'status': 'ended',
            'started_at': '2026-10-01T09:00:00Z',
            'answered_at': '2026-10-01T09:00:05Z',
            'ended_at': '2026-10-01T09:01:10Z',
          },
        ],
        currentUserId: 'me',
        profiles: {
          'peer-1': {
            'id': 'peer-1',
            'name': 'Amaka',
            'photo': 'https://example.com/a.jpg',
          },
        },
      );

      final call = calls.single;
      expect(call['matchId'], 'match-1');
      expect(call['peerId'], 'peer-1');
      expect(call['peerName'], 'Amaka');
      expect(call['peerPhoto'], 'https://example.com/a.jpg');
      expect(call['outgoing'], isTrue);
      expect(call['missed'], isFalse);
      expect(call['label'], 'Outgoing');
      expect(call['durationSeconds'], 65);
      expect(call['durationLabel'], '1:05');
    });

    test('flags an unanswered incoming ring as missed', () {
      final call = BackendService.normalizeCallHistory(
        [
          {
            'id': 'call-2',
            'match_id': 'match-1',
            'caller_id': 'peer-1',
            'callee_id': 'me',
            'status': 'ringing',
            'started_at': '2026-10-01T10:00:00Z',
          },
        ],
        currentUserId: 'me',
      ).single;

      expect(call['outgoing'], isFalse);
      expect(call['missed'], isTrue);
      expect(call['label'], 'Missed');
      expect(call['durationLabel'], '0:00');
      // A missing profile still renders a usable name.
      expect(call['peerName'], 'SawaLove member');
    });

    test('labels declines and sorts newest first', () {
      final calls = BackendService.normalizeCallHistory(
        [
          {
            'id': 'older',
            'caller_id': 'me',
            'callee_id': 'peer-1',
            'status': 'ended',
            'started_at': '2026-10-01T09:00:00Z',
          },
          {
            'id': 'newer',
            'caller_id': 'peer-1',
            'callee_id': 'me',
            'status': 'declined',
            'started_at': '2026-10-02T09:00:00Z',
          },
        ],
        currentUserId: 'me',
      );

      expect(calls.map((call) => call['id']), ['newer', 'older']);
      expect(calls.first['label'], 'Declined');
      expect(calls.last['label'], 'Outgoing');
    });
  });
}
