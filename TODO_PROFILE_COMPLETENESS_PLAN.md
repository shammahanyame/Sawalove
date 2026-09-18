# Profile Completeness Screen Implementation Plan

## Information Gathered
- **Existing profile features**: self_profile_screen.dart, completeness_screen.dart (stub)
- **Theme colors**: magenta #B30065, teal #1D9E75, purple #8329C8, amber verification
- **Riverpod pattern**: StateNotifier for state management
- **User model** needs completeness computation from Firestore fields
- **GoRouter** for task navigation to edit screens

## Plan
1. **lib/shared/providers/completeness_provider.dart** - CompletenessNotifier computing score
2. **lib/features/profile/widgets/ring_painter.dart** - CustomPainter for animated ring
3. **lib/features/profile/widgets/task_card.dart** - Task card with icon, bilingual text, points
4. **lib/features/profile/widgets/milestone_card.dart** - Scrollable milestone rewards
5. **lib/features/profile/completeness_screen.dart** - Main screen with ring, tasks, milestones
6. **lib/features/profile/widgets/nudge_card.dart** - Compact inline version
7. Update `self_profile_screen.dart` to show nudge card
8. Add Cloud Function stubs for reward claiming

## Dependent Files
- `lib/features/profile/self_profile_screen.dart` - Inline nudge card
- `lib/core/router/app_router.dart` - Task edit routes
- `lib/l10n/app_en.arb` - Bilingual strings
- `lib/shared/models/user_model.dart` - Completeness computation

## Followup Steps
- `flutter pub get`
- Test all 5 states (30%, 60% Boost, 85% Premium, 100% celebration, nudge)
- Verify ring animation 60fps, reward claiming

Ready to proceed?

