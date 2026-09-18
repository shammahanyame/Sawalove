# SawaLove Bug Fixing Tracker

**Approved Plan Progress: Check/fix every screen systematically.**

## 📋 Steps from Plan

### Phase 1: Priority Screens (Visible/Open)
- ✅ 1. Read lib/core/theme/theme.dart (check SawaLoveTheme)

- ✅ 2. Fix ethnicity_screen.dart (theme refs, dropdown layout, flags, validation/nav)

- ✅ 3. Fix phone_login_screen.dart (assets placeholders, Firebase stub, country selector)
- ✅ 4. Read lib/features/location/nearby_map_screen.dart & lib/shared/services/firebase_service.dart

- ✅ 5. Fix nearby_map_screen.dart (connectivity callback, strokePattern, deprecated accuracy, H3 stubs)

### Phase 2: Core Dependencies
- [ ] 6. Update firebase_service.dart (users getter, signInWithPhone)
- [ ] 7. Add missing assets (flags, icons) or placeholders
- [ ] 8. Fix onboarding_flow.dart navigation integration

### Phase 3: General Screens (from open tabs)
- [ ] 9. discovery_screen.dart
- [ ] 10. explore_screen.dart
- [ ] 11. likes_matches_screen.dart
- [ ] 12. match_success_screen.dart
- [ ] 13. chat_detail_screen.dart
- [ ] 14. peer_profile_screen.dart
- [ ] 15. self_profile_screen.dart

### Phase 4: Validation & Test
- ✅ 16. flutter pub get && flutter analyze
- [ ] 17. flutter gen-l10n
- [ ] 18. Update TODO_PROGRESS.md & TODO_SCREENS.md
- [ ] 19. flutter run - test flows
- [ ] 20. attempt_completion

**Instructions:** Update ✅ after each step. Use edit_file for changes.

