/// Agora configuration for SawaLove video calling.
///
/// The App ID is a public build-time value, passed like the Supabase ones:
///
///   flutter build apk --dart-define=AGORA_APP_ID=...
///
/// The App Certificate is a server secret and only ever lives in the
/// `agora-token` Edge Function.
class AgoraConfig {
  static const String appId = String.fromEnvironment('AGORA_APP_ID');

  /// False on builds without `--dart-define=AGORA_APP_ID`, which keeps the
  /// call screens from trying to join a channel they cannot authenticate.
  static bool get isConfigured => appId.trim().isNotEmpty;

  // Channel expiration time in seconds (1 hour)
  static const int tokenExpiry = 3600;

  // Default video encoding dimensions
  static const int defaultWidth = 640;
  static const int defaultHeight = 360;

  // Frame rate settings
  static const int defaultFrameRate = 15;
  static const int minFrameRate = 10;

  // Bitrate settings (kbps)
  static const int defaultBitrate = 800;
  static const int minBitrate = 200;

  // Connection quality thresholds
  static const double poorConnectionThreshold = 0.15;
  static const double criticalConnectionThreshold = 0.40;

  // Reconnection timeout (seconds)
  static const int reconnectTimeout = 30;

  // Call timeout (seconds) - auto-end if no answer
  static const int callTimeout = 30;

  // Auto-hide controls delay (seconds)
  static const int controlsHideDelay = 4;
}
