import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:sawalove/core/config/push_config.dart';
import 'package:sawalove/core/utils/logger.dart';
import 'package:sawalove/shared/services/backend_service.dart';

/// Runs in a separate isolate when a message arrives with the app in the
/// background or terminated. The `notify-call` Edge Function sends a
/// notification payload, so the OS displays the ring itself; the handler only
/// makes sure Firebase is initialised for data messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: PushConfig.options);
  }
}

/// Push plumbing for incoming calls.
///
/// Gated on [PushConfig.isConfigured]: without Firebase credentials this does
/// nothing, so the app behaves exactly as before. When configured it
/// registers the device token with Supabase and turns an `incoming_call`
/// message into a value on [incomingCall], which `MyApp` opens as the
/// incoming-call screen — foreground, backgrounded, or cold-started from the
/// notification.
class PushService {
  PushService._();

  /// Payload of the last incoming call that still needs to be opened.
  static final ValueNotifier<Map<String, dynamic>?> incomingCall =
      ValueNotifier<Map<String, dynamic>?>(null);

  static bool _started = false;

  static bool get isSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Never throws: push is optional and must not stop the app from starting.
  static Future<void> initialize() async {
    if (_started || !PushConfig.isConfigured || !isSupported) return;
    _started = true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: PushConfig.options);
      }

      final messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _register(token);
      }
      messaging.onTokenRefresh.listen(_register);
      // The first token is minted before sign-in, so store it again as soon as
      // a session exists (push_tokens rows belong to a user).
      BackendService().authStateChanges.listen((user) async {
        if (user == null) return;
        final current = await messaging.getToken();
        if (current != null && current.isNotEmpty) await _register(current);
      });

      FirebaseMessaging.onMessage.listen((message) {
        final call = incomingCallPayload(message.data);
        if (call != null) incomingCall.value = call;
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final call = incomingCallPayload(message.data);
        if (call != null) incomingCall.value = call;
      });

      // Cold start from the ringing notification.
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        final call = incomingCallPayload(initial.data);
        if (call != null) incomingCall.value = call;
      }
    } catch (e) {
      logger.w('Push notifications unavailable: $e');
    }
  }

  static Future<void> _register(String token) async {
    try {
      await BackendService().registerPushToken(token, platform: _platform);
    } catch (e) {
      // A device token that cannot be stored (for example another account
      // owns the row) must not break the session.
      logger.w('Could not register this device for calls: $e');
    }
  }

  /// Converts an FCM data payload into the extras `IncomingCallScreen` reads,
  /// or null when the message is not a call. FCM data values are strings.
  static Map<String, dynamic>? incomingCallPayload(Map<String, dynamic> data) {
    if (data['type']?.toString() != 'incoming_call') return null;
    final callId = data['callId']?.toString() ?? '';
    if (callId.isEmpty) return null;
    return <String, dynamic>{
      'callId': callId,
      'callerId': data['callerId']?.toString() ?? '',
      'callerName': data['callerName']?.toString() ?? 'Someone',
      'callerAvatar': data['callerAvatar']?.toString() ?? '',
      'matchId': data['matchId']?.toString() ?? '',
      'faith': data['faith']?.toString() ?? '',
      'superLikedYou': _isTrue(data['superLikedYou']),
      'isVerified': _isTrue(data['isVerified']),
    };
  }

  /// The `push_tokens.platform` value for this build. Split out from
  /// [_platform] so the mapping can be tested on any host platform.
  static String platformFor(TargetPlatform target, {bool web = false}) {
    if (web) return 'web';
    return switch (target) {
      TargetPlatform.iOS || TargetPlatform.macOS => 'ios',
      _ => 'android',
    };
  }

  static String get _platform => platformFor(defaultTargetPlatform, web: kIsWeb);

  static bool _isTrue(Object? value) =>
      value == true || value?.toString().toLowerCase() == 'true';
}
