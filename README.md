# SawaLove 🚀 Premium Dating App for Cameroon

[![Flutter](https://flutter.dev/images/FlutterLogo.png)](https://flutter.dev/) [![Riverpod](https://riverpod.dev/logo_long.png)](https://riverpod.dev/) [![Firebase](https://firebase.google.com/downloads/brand-guidelines/images/brand-download/firebase_standalone_logo.svg)](https://firebase.google.com/)

**SawaLove** – Premium dating/social app for Cameroonians (local + diaspora). Tinder-style swipes + deep localization: bilingual EN/FR, MTN/Orange Money, fields like Village/Region/Church. **Premium African Modern** design (Douala sunset palette).

## 🎯 MVP Screens (15 Total)
1. Phone Login/OTP
2. Onboarding (localized fields)
3. Photo Verification
4. Home/Discovery (swipe)
5. Explore (modes: friendship/dating/marriage)
6. Likes & Matches
7. Match Success (celebration)
8. Chat Detail (voice/video)
9. Peer Profile (Amaka-style)
10. Self Profile/Settings
11. Premium Checkout (Mobile Money)
12. Boost Success
13. Safety Center
14. Report User
15. Incognito Toggle

**Prototypes**: See `home_discovery/`, `explore_refined/` folders (code.html + screenshots).

## 🛠️ Tech Stack
```
Frontend: Flutter 3.24+ (Android/iOS/Web PWA)
State: Riverpod
Routing: GoRouter
Backend: Firebase (Auth/Firestore/Storage/FCM/Functions)
Auth: Phone OTP (+237)
Maps: geolocator + google_maps_flutter
Payments: MTN/Orange via Campay
Media: image_picker, camera, agora_rtc_engine
i18n: ARB (EN/FR)
```
[pubspec.yaml](./pubspec.yaml) | Full deps in [SETUP.md](./SETUP.md)

## 🎨 Design System
**Colors** (`lib/core/theme/theme.dart`):
```dart
static const primary = Color(0xFFB30065); // Magenta
static const secondary = Color(0xFF8329C8); // Purple
// No pure black – onSurface: Color(0xFF4A2134)
```
**Typography**: Plus Jakarta Sans (headings), Be Vietnam Pro (body).  
**Rules**: 16dp+ radius, glassmorphism nav, tonal elevation (no shadows).  
Details: [douala_sun/DESIGN.md](./douala_sun/DESIGN.md)

**Responsive**: Compact/Medium/Expanded breakpoints, landscape split-view.

## 🚀 Quick Start
See [SETUP.md](./SETUP.md) for Firebase/platforms.

```bash
flutter pub get
flutter run
```

**Build**:
```bash
flutter build apk --release --split-per-abi  # <25MB target
```

## 📱 Current Status
- [x] Theme system (M3, bilingual fonts)
- [x] Basic navigation (GoRouter + Riverpod)
- [x] Core screens stubbed (login, discovery, safety)
- [ ] Firebase integration
- [ ] Full 15 screens from prototypes
- Progress: [TODO.md](./TODO.md)

## 📂 Structure
```
lib/
├── core/     # theme, utils, splash
├── features/ # auth/, discovery/, chat/, etc.
├── shared/   # widgets/, services/
└── l10n/     # app_en.arb, app_fr.arb
```

## 🤝 Contributing
[CONTRIBUTING.md](./CONTRIBUTING.md)

## 📄 License
MIT. Built with ❤️ for Cameroon.


**SawaLove** is a premium dating and social networking app for the Cameroonian market (local + diaspora). Blends Tinder-style swiping with cultural localization: bilingual (English/French), MTN/Orange Mobile Money, profile fields like 'Village of Origin', 'Region', 'Church/Denomination'. Design: **Premium African Modern** – vibrant Douala sunset-inspired.

## ✨ Features (MVP Screens)

1. **Phone Login/OTP** – Bilingual toggle
2. **Onboarding/Sign-up** – Localized fields (hometown, region, church)
3. **Photo Verification** – Selfie liveness check
4. **Home/Discovery** – Swipe cards (Like/Nope)
5. **Explore** – Interest/mode browsing (friendship/dating/marriage)
6. **Likes & Matches** – Grid view
7. **Chat Detail** – Voice notes, video calls
8. **Peer Profile** – Full-screen Amaka-style
9. **Self Profile/Settings** – Edit, premium upsells
10. **Premium Checkout** – Mobile Money (MTN/Orange)
11. **Safety Center** – Block/report flows

See [TODO.md](./TODO.md) for implementation progress.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart) – Android/iOS/Web PWA
- **State**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Firebase (Auth/Firestore/Storage/FCM/Functions)
- **Auth**: Phone OTP primary
- **Maps**: `geolocator` + `google_maps_flutter`
- **Media**: `image_picker`, `record`, `agora_rtc_engine`
- **Payments**: Campay/MTN/Orange Money APIs
- **Localization**: ARB files (en/fr)

## 🎨 Design System: Premium African Modern

### Colors (`lib/core/theme/colors.dart`)
```dart
static const primary = Color(0xFFB30065);
static const primaryContainer = Color(0xFFFF6EA9);
static const secondary = Color(0xFF8329C8);
static const tertiary = Color(0xFF00647C);
static const surface = Color(0xFFFFF4F6);
// No pure black! Use onSurface: Color(0xFF4A2134)
```

### Typography
Google Fonts: **Plus Jakarta Sans** (headlines), **Be Vietnam Pro** (body).

| Token | Font | Size |
|-------|------|------|
| displayLarge | Plus Jakarta Sans | 56sp |
| headlineMedium | Plus Jakarta Sans | 28sp |
| bodyLarge | Be Vietnam Pro | 16sp |

**Rules**:
- Min radius: 16dp (FABs: 48dp pill)
- No 1px borders – use tonal layers/space
- Glassmorphism nav: `BackdropFilter(blur(12))`

Full details: [douala_sun/DESIGN.md](./douala_sun/DESIGN.md)

### Current Structure (Prototypes)
- Screen folders: `home_discovery/`, `chat_detail/` etc. (code.html + screen.png)
- Target Flutter structure: `lib/features/auth/`, `lib/shared/widgets/` (per spec)

## 🚀 Quick Setup & Run

### Prerequisites
- Flutter SDK 3.24+ ([install](https://docs.flutter.dev/get-started/install))
- Firebase project ([console.firebase.google.com](https://console.firebase.google.com))
- Android Studio/Xcode for emulators

### Steps
1. **Clone/Open Project**
   ```
   cd c:/Users/Anyame Shammah/Desktop/sawalove/sawalove
   ```

2. **Flutter Setup** (run once):
   ```
   flutter create .
   flutter pub get
   ```

3. **Firebase**:
   - Create project `sawalove-xyz`
   - Enable Auth (Phone), Firestore, Storage
   - Download `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
   - Add to `android/app/`, `ios/Runner/`
   - Run `flutterfire configure`

4. **Run App**
   ```
   flutter run
   ```
   - Android: `flutter run -d chrome` for web
   - Targets: mid-range Android (e.g., Tecno Spark)

### Build
```
flutter build apk --release
flutter build appbundle
```

## 📱 Responsive & Accessibility
- Breakpoints: Compact (<600dp), Medium (600-840), Expanded (>840dp)
- `textScaleFactor` support, WCAG AA contrast, `Semantics` labels (bilingual)

## 🔒 Safety & Privacy
- Photo verification mandatory
- Location: City/region only (no raw GPS)
- Incognito mode (Premium)
- Detailed reports, Firebase rules enforced

## 🤝 Contributing
1. Fork & PR to `main`
2. Follow [TODO.md](./TODO.md)
3. Lint: `flutter analyze`
4. Test: `flutter test`
5. Branch: `feature/screen-name`

See prototypes in screen folders for UI reference.

## 📄 License
MIT – Built with ❤️ for Cameroon.

---

*Production-grade, scalable to 100k+ users. No setState – Riverpod everywhere.*

