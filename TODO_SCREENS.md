# SawaLove Key Screens Implementation TODO ✅

**Approved Plan: Make 4 screens fully functional/bug-free.**  
Current progress: Stubs → Production-ready. Track here.

## 📋 Logical Steps (Sequential)

### Step 1: Dependencies & Setup
- ✅ Update pubspec.yaml: Add image_picker, camera, pinput, swipe_cards, confetti, google_ml_kit_face_detection (liveness stub).
- ✅ flutter pub get
- ✅ Update main.dart: Firebase.initializeApp()
- ✅ flutter gen-l10n

### Step 2: Shared Widgets
- ✅ Create lib/shared/widgets/pin_input.dart
- ✅ Create lib/shared/widgets/bilingual_toggle.dart
- ✅ Create lib/shared/widgets/swipe_card.dart

### Step 3: Auth Flow (Phone Login → OTP)
- ✅ Create lib/features/auth/phone_login_screen.dart (full UI per mockup)
- ✅ Edit lib/features/auth/otp_verification_screen.dart (PIN fields, timer, verify)
- [ ] Update FirebaseService: Implement phone auth callbacks/verifyOTP

### Step 4: Onboarding Flow
- ✅ Edit lib/features/onboarding/onboarding_flow.dart (multi-step forms: name/DOB/gender/photos/hometown/region/church/languages/intent)
- ✅ Update user_provider.dart: Onboarding state/saveProfile()

### Step 5: Photo Verification
- ✅ Create lib/features/onboarding/photo_verification_screen.dart (camera, oval overlay, good/bad examples)
- [ ] Update FirebaseService: Upload photo to storage

### Step 6: Home Discovery Swipe
- ✅ Create lib/features/discovery/discovery_screen.dart (Tinder cards, gestures, controls)
- ✅ Update discovery_provider.dart: Stream profiles, swipe like/match logic

### Step 7: Router & Integration
- ✅ Edit app_router.dart: Wire all screens (imports/builders)
- [ ] Update ARBs: All strings bilingual

### Step 8: Additional Screens (All ✅ from VSCode tabs)
- ✅ ExploreScreen (modes: friendship/dating/marriage/networking)
- ✅ LikesMatchesScreen (grid matches/likes)
- ✅ MatchSuccessScreen (animated celebration)
- ✅ ChatDetailScreen (messages, voice notes, video call)
- ✅ PeerProfileScreen (full-screen view)
- ✅ SelfProfileScreen (edit, settings, premium)

### Step 9: New Screens (Feedback)
- [ ] PremiumCheckoutScreen
- [ ] BoostSuccessScreen  
- [ ] SafetyCenterScreen
- [ ] ReportUserScreen
- [ ] Incognito toggle (in settings)

### Step 10: Test & Polish
- [ ] Add loading/error states, validations, animations
- [ ] flutter analyze && flutter test
- [ ] flutter run - test full flow on device

**Progress: Update ✅ after each step completion.**  
Run `flutter run` after Step 8 to verify no bugs.

