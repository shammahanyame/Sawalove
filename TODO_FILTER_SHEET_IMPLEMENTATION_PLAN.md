# Filter Sheet Implementation Plan

## Information Gathered

### Project Structure
- **Flutter Dating App** for Cameroonians (SawaLove)
- Uses **Riverpod** for state management
- **GoRouter** for navigation
- Existing `preferences_provider.dart` has partial filter state but needs extension
- `discovery_screen.dart` needs filter button integration
- Theme colors established: `primary: #B30065` (magenta), `secondary: #8329C8` (purple), `tertiary: #00647C` (teal)

### Key Requirements from Spec
1. **Bottom Sheet** presentation (DraggableScrollableSheet with 3 snap points: 0.55, 0.85, 1.0)
2. **Live Pool Counter** with AnimatedSwitcher, color shifts (magenta→amber→teal)
3. **5 Filter Sections**: Age range, Distance, Interested in, Looking for, Faith, Region (unique), Lifestyle
4. **Active Pills Summary Row** - dismissable chips for quick filter removal
5. **Presets** - Premium-only feature with Firestore storage
6. **Reset Confirmation Modal** - bilingual Stack overlay
7. **Apply/Discard behavior** with snapshot rollback

### Colors from Theme
- Magenta (primary): `#B30065`
- Amber (warning): `#BA7517`
- Teal (abundance): `#00647C`
- Purple (faith): `#8329C8`

## Plan

### Step 1: Create Filter State & Provider (Extend PreferencesProvider)
**Files to modify:**
- `lib/shared/providers/preferences_provider.dart` - Rename to filterProvider, add new fields (faiths, regions, lifestyles, onlineNow, withPhoto), methods (toggleFaith, toggleRegion, toggleLifestyle, saveSnapshot, restore, setApplied, removeFilter, clearAll, savePreset)

### Step 2: Create Filter Sheet Widget
**New files:**
- `lib/features/discovery/widgets/filter_sheet.dart` - Main filter sheet with all sections
- `lib/features/discovery/widgets/filter_pill_chip.dart` - Dismissable pill widget
- `lib/features/discovery/widgets/reset_modal.dart` - Reset confirmation modal
- `lib/features/discovery/widgets/pool_counter_card.dart` - Pool counter with animations

### Step 3: Integrate with Discovery Screen
**Files to modify:**
- `lib/features/discovery/discovery_screen.dart` - Add filter button in AppBar, showFilterSheet function
- `lib/core/router/app_router.dart` - Ensure routes are set up

### Step 4: Add Localization Strings
**Files to modify:**
- `lib/l10n/app_en.arb` - English strings
- `lib/l10n/app_fr.arb` - French strings

### Step 5: Demo States & Testing
- Add demo state helpers in filter provider
- Test all 5 states: Default, Filters Active, Too Narrow, Active Pills, Reset Modal

## File Creation Order
1. `filter_pill_chip.dart` - Supporting widget
2. `reset_modal.dart` - Supporting widget  
3. `pool_counter_card.dart` - Supporting widget
4. `filter_sheet.dart` - Main implementation
5. Update `preferences_provider.dart` → `filter_provider.dart`
6. Update `discovery_screen.dart`
7. Add localization strings

## Dependent Files to be Edited
- `lib/features/discovery/discovery_screen.dart` - Add filter icon button
- `lib/shared/providers/preferences_provider.dart` - Extend for filter functionality
- `lib/l10n/app_en.arb` - Add filter-related strings
- `lib/l10n/app_fr.arb` - Add filter-related strings

## Followup Steps
1. Run `flutter pub get` to ensure dependencies
2. Run `flutter analyze` to check for lints
3. Test on device: drag sheet, pool animations, apply/rollback, pills dismiss
4. Verify 60fps during slider drag with RepaintBoundary
