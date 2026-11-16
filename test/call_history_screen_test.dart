// Call history screen states: loading, empty, populated, failed + retry.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/features/chat/call_history_screen.dart';

Widget _screen(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: SawaLoveTheme.lightTheme,
      home: const CallHistoryScreen(),
    ),
  );
}

List<Map<String, dynamic>> _history() => [
      {
        'id': 'call-1',
        'matchId': 'match-1',
        'peerName': 'Amaka',
        'peerPhoto': '',
        'outgoing': true,
        'missed': false,
        'label': 'Outgoing',
        'durationLabel': '1:05',
      },
      {
        'id': 'call-2',
        'matchId': 'match-1',
        'peerName': 'Bih',
        'peerPhoto': '',
        'outgoing': false,
        'missed': true,
        'label': 'Missed',
        'durationLabel': '0:00',
      },
    ];

void main() {
  // Tests must not fetch font files over the network.
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows a spinner until the calls arrive', (tester) async {
    await tester.pumpWidget(_screen([
      callHistoryProvider.overrideWith(
        (ref) => Future<List<Map<String, dynamic>>>.delayed(
          const Duration(seconds: 1),
          () => const [],
        ),
      ),
    ]));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets('explains an empty history', (tester) async {
    await tester.pumpWidget(_screen([
      callHistoryProvider.overrideWith((ref) async => const []),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('No calls yet'), findsOneWidget);
    expect(
      find.text('Video calls you make or take show up here.'),
      findsOneWidget,
    );
  });

  testWidgets('renders each call with its direction and duration',
      (tester) async {
    await tester.pumpWidget(_screen([
      callHistoryProvider.overrideWith((ref) async => _history()),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Amaka'), findsOneWidget);
    expect(find.text('Bih'), findsOneWidget);
    expect(find.text('Outgoing · 1:05'), findsOneWidget);
    expect(find.text('Missed · 0:00'), findsOneWidget);
    expect(find.byIcon(Icons.call_made), findsOneWidget);
    expect(find.byIcon(Icons.call_missed), findsOneWidget);
  });

  testWidgets('offers a call-back button only when the match is known',
      (tester) async {
    await tester.pumpWidget(_screen([
      callHistoryProvider.overrideWith((ref) async => [
            ..._history(),
            {
              'id': 'call-3',
              'matchId': '',
              'peerName': 'Chidi',
              'peerPhoto': '',
              'outgoing': false,
              'missed': false,
              'label': 'Incoming',
              'durationLabel': '0:12',
            },
          ]),
    ]));
    await tester.pumpAndSettle();

    // Two rows carry a match id, the third does not.
    expect(find.byIcon(Icons.videocam_outlined), findsNWidgets(2));
  });

  testWidgets('reports a failed load and retries on demand', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(_screen([
      callHistoryProvider.overrideWith((ref) async {
        attempts += 1;
        if (attempts == 1) throw StateError('offline');
        return const <Map<String, dynamic>>[];
      }),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Could not load your calls.'), findsOneWidget);
    expect(attempts, 1);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    // The retry recovered into the empty state.
    expect(find.text('No calls yet'), findsOneWidget);
  });
}
