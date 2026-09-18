# TODO: Incoming Call Screen Implementation Plan

## Analysis Summary

### Files Gathered
1. `lib/features/chat/incoming_call_screen.dart` - Existing basic ringing screen
2. `lib/features/chat/providers/video_call_provider.dart` - Call state provider
3. `lib/core/theme/theme.dart` - SawaLoveTheme colors
4. `lib/l10n/app_en.arb` and `app_fr.arb` - Localization files

### Key Insights
- SawaLoveTheme has brand colors: primary (#B30065), primaryContainer (#FF6EA9), secondary (#8329C8)
- VideoCallProvider has CallState enum: connecting, active, muted, cameraOff, ended, summary
- Existing IncomingCallScreen is basic with simple toggle animation
- Uses simple tap buttons instead of slide-to-answer

## Implementation Plan

### Phase 1: Data Models & State Management
- [ ] 1.1 Expand CallState enum with: ringing, declined, missedCall, busyUnavailable, reminderScheduled
- [ ] 1.2 Create IncomingCallData model class for call parameters
- [ ] 1.3 Create CallNotificationController provider for managing overlays

### Phase 2: Ringing Screen (Full Enhancement)
- [ ] 2.1 Three animated pulse rings (scale 1.0→1.54, fade 0.3→0, 1.8s duration, 600ms stagger)
- [ ] 2.2 Slide-to-answer widget (GestureDetector, velocity threshold 400px/s)
- [ ] 2.3 Slide-to-decline widget
- [ ] 2.4 Contextual badge chips (Super Liked, Verified, faith)
- [ ] 2.5 Quick action buttons (Message, Remind, Busy)

### Phase 3: App Foreground Banner
- [ ] 3.1 Create CallBannerWidget (OverlayEntry)
- [ ] 3.2 SlideTransition animation (350ms, easeOutCubic)
- [ ] 3.3 Accept/Decline tap buttons
- [ ] 3.4 Auto-dismiss timer (30 seconds)

### Phase 4: Declined Screen
- [ ] 4.1 Dark crimson background
- [ ] 4.2 Gentle message: "X declined"
- [ ] 4.3 Quick message CTA
- [ ] 4.4 Manual message option
- [ ] 4.5 Auto-routing (8 seconds)

### Phase 5: Missed Call Bubble
- [ ] 5.1 MissedCallBubble widget for chat list/detail
- [ ] 5.2 Red-tinted background, phone icon
- [ ] 5.3 Time display and "Call back" link
- [ ] 5.4 Push notification template

### Phase 6: Busy/Unavailable Screen
- [ ] 6.1 Deep blue gradient background
- [ ] 6.2 Explicit reason message
- [ ] 6.3 Voice message recorder button (60s max)

### Phase 7: View Transitions & Accessibility
- [ ] 7.1 View transition animations (0.25s, cubic-bezier)
- [ ] 7.2 Semantics labels for all interactive elements

## Files to Create
1. `lib/features/chat/models/incoming_call_data.dart`
2. `lib/features/chat/widgets/slide_to_answer.dart`
3. `lib/features/chat/widgets/pulsing_ring.dart`
4. `lib/features/chat/widgets/call_quick_actions.dart`
5. `lib/features/chat/widgets/call_banner_widget.dart`
6. `lib/features/chat/widgets/missed_call_bubble.dart`
7. `lib/features/chat/declined_call_screen.dart`
8. `lib/features/chat/busy_unavailable_screen.dart`
9. `lib/features/chat/call_notification_controller.dart`

## Files to Modify
1. `lib/features/chat/incoming_call_screen.dart` - Full rewrite
2. `lib/features/chat/providers/video_call_provider.dart` - Expand states
3. `lib/core/router/app_router.dart` - Add routes

## Localization Keys (app_en.arb)
- "incomingCallTitle": "Incoming video call from {name}"
- "slideToAnswer": "SLIDE TO ANSWER · GLISSER"
- "message": "Message · Texte"
- "remind": "Remind · Rappel"
- "busy": "Busy · Occupé"
- "declined": "{name} declined"
- "missedCall": "Missed video call · Appel vidéo manqué"
- "callBack": "Call back"
- "busyUnavailable": "She may be on another call or has Do Not Disturb enabled"
- "voiceMessage": "Leave voice message · Message vocal"
