import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:sawalove/core/utils/logger.dart';
import 'package:sawalove/shared/services/backend_service.dart';

/// Rings incoming calls while the app is in the foreground.
///
/// FCM is the only way to reach a closed app, but it needs Firebase
/// credentials and a granted notification permission. This poller covers the
/// rest: every few seconds it asks the backend for a still-ringing call
/// addressed to the signed-in user and raises [ring], which `MyApp` opens as
/// the incoming-call screen. That keeps calls working on a build without
/// `FIREBASE_*` defines, on web, and on a device where notifications were
/// denied.
///
/// Nothing here runs until a session exists, and polling pauses with the app.
class CallRinger {
  CallRinger._();

  /// A ring waiting to be opened. `MyApp` clears it after navigating.
  static final ValueNotifier<Map<String, dynamic>?> ring =
      ValueNotifier<Map<String, dynamic>?>(null);

  /// How often the fallback looks for a call: short enough that the caller
  /// does not ring into silence, long enough to stay cheap.
  static Duration interval = const Duration(seconds: 6);

  static Timer? _timer;
  static bool _initialized = false;
  static bool _foreground = true;

  /// The ring already handed to the UI, so a poll that still sees the same
  /// call does not reopen the screen after the user declined or answered.
  static String? _raisedCallId;

  /// Never throws: ringing is optional and must not stop the app from starting.
  static void initialize({BackendService? backend}) {
    if (_initialized) return;
    _initialized = true;

    final service = backend ?? BackendService();
    if (!service.isConfigured) return;

    WidgetsBinding.instance.addObserver(_LifecycleWatcher());
    _foreground =
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused;

    service.authStateChanges.listen((user) {
      if (user == null) {
        _stop();
        _raisedCallId = null;
        ring.value = null;
      } else {
        _start(service);
      }
    });

    if (service.currentUserId != null) _start(service);
  }

  /// Drops the current ring without touching the call itself.
  static void clear() {
    ring.value = null;
  }

  static void _start(BackendService service) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _poll(service));
    // Do not make the first ring wait a whole interval.
    unawaited(_poll(service));
  }

  static void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _poll(BackendService service) async {
    if (!_foreground || ring.value != null) return;
    try {
      final call = await service.fetchIncomingRing();
      if (call == null) return;

      final callId = call['callId']?.toString() ?? '';
      if (callId.isEmpty || callId == _raisedCallId) return;

      _raisedCallId = callId;
      ring.value = call;
      logger.i('Ringing incoming call $callId (foreground fallback)');
    } catch (e) {
      // A dropped poll is retried on the next tick.
      logger.w('Could not check for incoming calls: $e');
    }
  }
}

class _LifecycleWatcher with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    CallRinger._foreground = state == AppLifecycleState.resumed;
  }
}
