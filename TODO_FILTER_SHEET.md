# Filter Sheet Implementation TODO

## Step 1: Extend PreferencesProvider → FilterNotifier
- [x] Add new fields: `faiths`, `regions`, `lifestyles`, `onlineNow`, `withPhoto`, `savedSnapshot`, `wasApplied`
- [x] Add new methods: `toggleFaith`, `toggleRegion`, `toggleLifestyle`, `saveSnapshot()`, `restore(snapshot)`, `setApplied(bool)`, `removeFilter(key)`, `clearAll()`, `savePreset`, `loadPresets`
- [x] Enhance pool count logic for new fields
- [x] Rename provider key to `filterProvider`

## Step 2: Create Filter Sheet Widget
- [ ] `lib/features/discovery/widgets/filter_sheet.dart`
- [x] DraggableScrollableSheet (snap 0.55/0.85/1.0)
- [x] Sticky header (back arrow, Reset all red when active)
- [x] Pool counter card (AnimatedSwitcher + AnimatedContainer + color shift magenta→amber/teal + warning banner)
- [x] Active pills summary row (SingleChildScrollView, dismissable pills)
- [x] Age range dual-thumb slider section (white card + magenta pill badge)
- [x] Distance single-thumb slider section ("Anywhere" 500km)
- [x] Interested in chips (magenta)
- [x] Looking for chips (intents)
- [x] Faith chips (purple #8329C8)
- [x] Region chips (teal, cities + Diaspora)
- [x] Lifestyle toggles as chips (magenta)
- [x] Toggle card rows: Online now, Has profile photo
- [x] Apply CTAs (sticky bottom)
- [x] Preset row (Premium, disabled for free)
- [x] Reset confirmation modal (Stack overlay)

## Step 3: Create Supporting Widgets
- [ ] `filter_pill_chip.dart` — dismissable pill with fade-out animation
- [ ] `reset_modal.dart` — centered bilingual modal with Go back/Reset

## Step 4: Integrate with Discovery
- [x] Add filter button to `discovery_screen.dart` app bar
- [x] Enhance `discovery_provider.dart` with filter query params
- [x] Hook `showFilterSheet()` function (modalBottomSheet + rollback)

## Step 5: Premium & Presets
- [x] Add Premium check stub for presets
- [x] Firestore /users/{uid}/filterPresets stub

## Step 6: Accessibility
- [x] Add Semantics on all interactive elements
- [x] liveRegion: true on pool counter
- [x] Semantic labels for all chips/sliders/buttons

## Step 7: Data & Assets
- [x] Regions list (Douala, Yaoundé, Bafoussam, Bamenda, Garoua, Maroua, Diaspora)
- [x] Lifestyles list (Non-smoker, No children, Verified only, Active this week)
- [x] Colors verified (magenta #B30065, amber #BA7517, teal, purple #8329C8)

## Step 8: Demo States
- [x] Default state
- [x] Filters active state
- [x] Too Narrow amber warning
- [x] Active pills summary row
- [x] Reset confirmation modal

## Step 9: Testing
- [ ] `flutter pub get` after deps
- [ ] `flutter analyze` (fix lints)
- [ ] `flutter run -d chrome` — drag sheet, pool anims, apply/rollback, pills dismiss
- [ ] 60fps during slider drag (RepaintBoundary)
