# SawaLove TODO Progress Tracker

✅ **Step 1 Complete**: pubspec.yaml updated. All deps added (Firebase full suite, maps, RTC, etc.). Run `flutter pub get` manually if needed.

✅ **Step 2 Complete**: FirebaseService created (`lib/shared/services/firebase_service.dart` – Auth/Firestore/Storage/Messaging/Analytics).

✅ **Step 3 Complete**: Full GoRouter tree (`lib/core/router/app_router.dart` – ShellRoute bottom nav, 15+ routes, deep links) + app.dart updated (localizations, routerProvider).

✅ **Step 4 Complete**: Core providers stubbed (`lib/shared/providers/user_provider.dart`).

✅ **Step 5 Complete**: main.dart Firebase init + runApp async.

✅ **Step 6 Pending**: `flutter gen-l10n` + expand ARB strings.

✅ **Step 7 Complete**: DiscoveryScreen uses Riverpod (ConsumerStatefulWidget with providers).

✅ **Step 8 Complete**: BottomNav ShellRoute implementation (glassmorphism). GlassBottomNav integrated with 5 tabs matching router paths.

**Next Steps**:
- [ ] Step 9: Run `flutter gen-l10n` to generate localization files.
- [ ] Step 10: Connect DiscoveryScreen to Firebase (refactor provider to use Firestore).
- [ ] Step 11: Implement auth state listening (redirect to login or onboarding).

Progress: Backend/router foundations ✅. Glassmorphism bottom nav ✅. Core app navigable post-init. `flutter run` testable.


Updated: Mark ✅ when complete. Run `flutter analyze` after each.

