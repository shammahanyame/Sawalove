import 'package:firebase_core/firebase_core.dart';

/// Firebase Cloud Messaging configuration for incoming-call ringing.
///
/// Nothing here is secret: these are the public client identifiers of the
/// Firebase project. They are build-time values, exactly like
/// `AGORA_APP_ID`, so an unconfigured build ships with no push support
/// instead of failing at runtime.
///
///   flutter build apk \
///     --dart-define=FIREBASE_API_KEY=... \
///     --dart-define=FIREBASE_APP_ID=... \
///     --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
///     --dart-define=FIREBASE_PROJECT_ID=...
///
/// Passing the options explicitly means the build does not need a checked-in
/// `google-services.json` / `GoogleService-Info.plist`.
class PushConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'io.sawalove.app',
  );

  static bool get isConfigured =>
      apiKey.trim().isNotEmpty &&
      appId.trim().isNotEmpty &&
      messagingSenderId.trim().isNotEmpty &&
      projectId.trim().isNotEmpty;

  static FirebaseOptions get options => FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket.isEmpty ? null : storageBucket,
        iosBundleId: iosBundleId,
      );
}
