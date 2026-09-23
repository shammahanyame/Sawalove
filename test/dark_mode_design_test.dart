// Dark-mode and design-system regression tests.
//
// Guards the design pass:
// - dark theme exists with berry palette and full type scale
// - bottom nav tabs keep >= 44px touch targets and fill icons when active
// - PressableScale gives visible press feedback (scale 0.96)
// - chat rows use theme tokens (readable in dark mode)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/features/chat/chat_list_screen.dart';
import 'package:sawalove/shared/models/inbox_item.dart';
import 'package:sawalove/shared/providers/inbox_provider.dart';
import 'package:sawalove/shared/widgets/glass_bottom_nav.dart';
import 'package:sawalove/shared/widgets/pressable_scale.dart';

/// InboxNotifier whose initial empty stream can be overridden by seeding
/// [state] after the first pump (the base constructor loads an empty list).
class _FakeInboxNotifier extends InboxNotifier {
  _FakeInboxNotifier() : super(InboxRepository(), '');
}

void main() {
  // Tests must not hit the network for font files; assertions on size,
  // weight and color still work with the fallback font.
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SawaLoveTheme', () {
    test('exposes a dark theme with dark brightness and berry surface', () {
      final dark = SawaLoveTheme.darkTheme;
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, const Color(0xFF1A0B1D));
      expect(dark.colorScheme.primary, const Color(0xFFFF6EA9));
      expect(dark.colorScheme.onSurface, const Color(0xFFF4DEE8));
    });

    test('light theme keeps the blush surface', () {
      final light = SawaLoveTheme.lightTheme;
      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, SawaLoveTheme.surface);
    });

    test('type scale defines every Material 3 role', () {
      final roles = SawaLoveTheme.darkTheme.textTheme;
      for (final role in [
        roles.displayLarge,
        roles.displayMedium,
        roles.displaySmall,
        roles.headlineLarge,
        roles.headlineMedium,
        roles.headlineSmall,
        roles.titleLarge,
        roles.titleMedium,
        roles.titleSmall,
        roles.bodyLarge,
        roles.bodyMedium,
        roles.bodySmall,
        roles.labelLarge,
        roles.labelMedium,
        roles.labelSmall,
      ]) {
        expect(role, isNotNull, reason: 'every text role must be defined');
      }
      expect(roles.headlineMedium!.fontSize, 28);
      expect(roles.bodyMedium!.fontSize, 14);
      expect(roles.bodyLarge!.height, 1.5);
    });

    test('body text colors follow the active theme', () {
      expect(
        SawaLoveTheme.lightTheme.textTheme.bodyLarge!.color,
        SawaLoveTheme.onSurface,
      );
      expect(
        SawaLoveTheme.darkTheme.textTheme.bodyLarge!.color,
        SawaLoveTheme.darkOnSurface,
      );
    });

    test('semantic status colors are distinct', () {
      expect(SawaLoveTheme.success, isNot(SawaLoveTheme.errorColor));
      expect(SawaLoveTheme.success, isNot(SawaLoveTheme.warning));
      expect(SawaLoveTheme.warning, isNot(SawaLoveTheme.errorColor));
    });
  });

  group('GlassBottomNav', () {
    late int tappedIndex;

    Future<void> pumpNav(WidgetTester tester) async {
      tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          theme: SawaLoveTheme.darkTheme,
          home: Scaffold(
            bottomNavigationBar: GlassBottomNav(
              currentIndex: 0,
              onTap: (i) => tappedIndex = i,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders all five tabs with labels', (tester) async {
      await pumpNav(tester);
      for (final label in ['Discover', 'Explore', 'Likes', 'Chats', 'Profile']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('tabs meet the 44px minimum touch target', (tester) async {
      await pumpNav(tester);
      final tabs = find.byType(PressableScale);
      expect(tabs, findsNWidgets(5));
      for (var i = 0; i < 5; i++) {
        final size = tester.getSize(tabs.at(i));
        expect(size.width, greaterThanOrEqualTo(44),
            reason: 'tab $i is narrower than 44px');
        expect(size.height, greaterThanOrEqualTo(44),
            reason: 'tab $i is shorter than 44px');
      }
    });

    testWidgets('tapping a tab reports its index', (tester) async {
      await pumpNav(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 4);
    });

    testWidgets('active tab uses the filled icon, inactive uses outline',
        (tester) async {
      await pumpNav(tester); // Discover (index 0) is active
      // Discover active -> filled heart; Likes inactive -> outline heart.
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });

  group('PressableScale', () {
    testWidgets('scales down while pressed and back up on release',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressableScale(
                onTap: () => taps++,
                child: const SizedBox(width: 100, height: 48),
              ),
            ),
          ),
        ),
      );

      double currentScale() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

      expect(currentScale(), 1.0);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressableScale)),
      );
      await tester.pump();
      expect(currentScale(), 0.96, reason: 'pressed state should scale down');

      await gesture.up();
      await tester.pumpAndSettle();
      expect(currentScale(), 1.0, reason: 'release should restore scale');
      expect(taps, 1);
    });

    testWidgets('stays at scale 1.0 when no handler is set',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressableScale(child: SizedBox(width: 100, height: 48)),
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressableScale)),
      );
      await tester.pump();
      final scale =
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
      expect(scale, 1.0);
      await gesture.up();
    });
  });

  group('ChatListScreen (dark theme)', () {
    testWidgets('renders an unread row with token-based surfaces',
        (tester) async {
      final notifier = _FakeInboxNotifier();
      await tester.pumpWidget(
        MaterialApp(
          theme: SawaLoveTheme.darkTheme,
          home: ProviderScope(
            overrides: [
              inboxProvider.overrideWith((ref) => notifier),
            ],
            child: const ChatListScreen(),
          ),
        ),
      );
      // Let the base constructor's empty stream deliver first, then seed.
      await tester.pump();
      notifier.state = AsyncValue.data([
        InboxItem(
          matchId: 'm1',
          matchName: 'Amaka',
          avatarUrl: 'https://example.com/a.jpg',
          unreadCount: 3,
          messageCount: 2,
          lastMessagePreview: 'Hey, how are you?',
          lastMessageAt: DateTime.now(),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Amaka'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // The unread row background is the lightest surface token, so it works
      // in both themes (previously hardcoded Colors.white).
      final rowContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final rowDecoration = rowContainer.decoration as BoxDecoration?;
      expect(rowDecoration?.color, SawaLoveTheme.surfaceContainerLowest);
    });
  });
}
