# SawaLove - All Remaining Screens Implementation
**Approved Plan Execution | Progress Tracker**

## Steps from Plan (Mark ✅ when done)

### Phase 1: Dependencies & Setup [ ]
- [ ] Step 1.1: Update pubspec.yaml with missing deps (audio, maps, payments, emoji, etc.)
- [ ] Step 1.2: `flutter pub get`
- [ ] Step 1.3: `flutter gen-l10n`
- [ ] Step 1.4: `flutter analyze` (fix to 0 errors)

### Phase 2: Priority Missing Screens [ ]
- [ ] Step 2.1: Create lib/features/chat/widgets/message_reaction_picker.dart (reactions/emoji tray)
- [ ] Step 2.2: Create lib/features/chat/widgets/waveform_scrubber.dart + integrate in voice_note_bubble.dart
- [ ] Step 2.3: Create lib/features/notifications/notification_center_screen.dart
- [ ] Step 2.4: Create lib/features/auth/unmatch_confirmation_screen.dart + warning_reason_screen.dart
- [ ] Step 2.5: Create lib/features/premium/purchase_history_screen.dart + receipt_screen.dart

### Phase 3: Complete Partial Screens [ ]
- [ ] Step 3.1: Enhance incoming_call_screen.dart per TODO_INCOMING_CALL (accept/decline modal full)
- [ ] Step 3.2: Add waveform/scrub/reactions/GIF/sticker/icebreakers to chat_detail_screen.dart
- [ ] Step 3.3: Integrate payments/boost timer in premium screens/discovery

### Phase 4: Settings & Safety [ ]
- [ ] Step 4.1: notification_settings_screen.dart, privacy_settings_screen.dart, blocked_users_screen.dart
- [ ] Step 4.2: location_rationale_screen.dart, suggest_meetup_screen.dart
- [ ] Step 4.3: moderation_appeal_screen.dart, help_faq_screen.dart, contact_support_screen.dart

### Phase 5: Polish & Test [ ]
- [ ] Step 5.1: Update app_router.dart with all routes
- [ ] Step 5.2: Add 100+ l10n keys to app_en.arb/app_fr.arb
- [ ] Step 5.3: Fix all linter errors
- [ ] Step 5.4: `flutter run` - full app runs error-free
- [ ] Step 5.5: Test key flows (chat features, premium, settings)

Current: Starting Phase 1
