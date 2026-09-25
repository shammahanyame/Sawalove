/// Build-time feature flags for the Play Store release.
///
/// All flags are compile-time constants (`--dart-define`), so dead code is
/// tree-shaken out of the release binary.
///
/// Release policy (Play Store):
///  - The production release MUST be built with the defaults below:
///      `SHIP_COMPLETE_FEATURES_ONLY` defaults to **true**  (stubs hidden)
///      `SHOW_PREMIUM`                 defaults to **false** (no fake checkout)
///      `SHOW_DEMO_HELPERS`            defaults to **false** (no demo menus)
///  - `android/app/build.gradle.kts` fails `bundleRelease`/`assembleRelease`
///    if `SHIP_COMPLETE_FEATURES_ONLY=false` is passed, so an unfinished
///    release build cannot be produced by accident.
///
/// For local development you can re-enable features explicitly:
///   flutter run --dart-define=SHIP_COMPLETE_FEATURES_ONLY=false
const bool kShipCompleteFeaturesOnly = bool.fromEnvironment(
  'SHIP_COMPLETE_FEATURES_ONLY',
  defaultValue: true,
);

/// Premium subscriptions are hidden until Google Play Billing is integrated.
/// Play's Payments policy forbids selling digital subscriptions with
/// Mobile Money inside the app, so the checkout stays out of release builds.
const bool kShowPremium = bool.fromEnvironment(
  'SHOW_PREMIUM',
  defaultValue: false,
);

/// Developer-only demo helper menus (fake state switchers).
const bool kShowDemoHelpers = bool.fromEnvironment(
  'SHOW_DEMO_HELPERS',
  defaultValue: false,
);

/// Features whose UI exists but has no working backend yet. When
/// [kShipCompleteFeaturesOnly] is true these are replaced by a "Coming soon"
/// screen instead of pretending to work.
///
/// Chat and Likes/Matches are backed by real API endpoints
/// (`/matches`, `/messages`, `/likes`) and are therefore ALWAYS on — the
/// remaining flags stay gated until their backends exist.
const bool kShowChat = true;
const bool kShowCalls = !kShipCompleteFeaturesOnly;
const bool kShowLikesAndMatches = true;
const bool kShowSos = !kShipCompleteFeaturesOnly;
const bool kShowIdVerification = !kShipCompleteFeaturesOnly;
const bool kShowNearbyMap = !kShipCompleteFeaturesOnly;
const bool kShowSuperLike = !kShipCompleteFeaturesOnly;
