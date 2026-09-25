import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sawalove/core/age_gate_screen.dart';
import 'package:sawalove/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

Widget _wrap(
  Widget child, {
  required Future<DateTime?> Function(BuildContext) onPick,
}) {
  final router = GoRouter(
    initialLocation: '/age-gate',
    routes: [
      GoRoute(
        path: '/age-gate',
        builder: (c, s) => AgeGateScreen(datePicked: onPick),
      ),
      GoRoute(path: '/login', builder: (c, s) => const Text('LOGIN-REACHED')),
      GoRoute(
        path: '/profile/terms',
        builder: (c, s) => const Text('TERMS-REACHED'),
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

// Fixed reference date so age arithmetic in tests is deterministic.
// _isAdult compares against DateTime.now(), so pick dates far from the
// boundary: 30 years old passes, 8 years old is blocked regardless of
// month/day drift between test run time and these constants.
Future<void> _pumpGate(WidgetTester tester, DateTime dob) async {
  await tester.pumpWidget(_wrap(
    const AgeGateScreen(),
    onPick: (_) async => dob,
  ));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Select date of birth'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('blocks an under-18 DOB and shows the adult-only error',
      (tester) async {
    final now = DateTime.now();
    // 8 years old: safely below the boundary.
    final dob = DateTime(now.year - 8, 6, 15);

    await _pumpGate(tester, dob);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('only for adults'), findsOneWidget);
    expect(find.text('LOGIN-REACHED'), findsNothing);
  });

  testWidgets('requires a DOB before continuing', (tester) async {
    await tester.pumpWidget(_wrap(
      const AgeGateScreen(),
      onPick: (_) async => null, // user cancelled the dialog
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Select your date of birth'), findsOneWidget);
    expect(find.text('LOGIN-REACHED'), findsNothing);
  });

  testWidgets('accepts an adult DOB, navigates to login and persists the DOB',
      (tester) async {
    final now = DateTime.now();
    // 30 years old: safely above the boundary.
    final dob = DateTime(now.year - 30, 6, 15);

    await _pumpGate(tester, dob);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN-REACHED'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('sawalove.declared_dob_iso');
    expect(stored, isNotNull);
    expect(DateTime.parse(stored!).year, dob.year);
  });

  testWidgets('cancelling the picker keeps the gate unresolved',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const AgeGateScreen(),
      onPick: (_) async => null,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select date of birth'));
    await tester.pumpAndSettle();

    // Still showing the placeholder — no date was committed.
    expect(find.text('Select date of birth'), findsOneWidget);
    expect(find.text('LOGIN-REACHED'), findsNothing);
  });
}
