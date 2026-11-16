import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/agora_config.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/services/backend_service.dart';

// Connection quality enum
enum ConnectionQuality {
  excellent,
  good,
  poor,
  reconnecting,
  disconnected,
}

// Video effect type
enum VideoEffect {
  none,
  warmGlow,
  softFocus,
  blurBg,
}

// Call state enum
enum CallState {
  connecting,
  active,
  muted,
  cameraOff,
  poorConnection,
  reconnecting,
  ended,
  summary,
}

// Video call state class
class VideoCallState {
  final CallState state;
  final bool remoteJoined;
  final bool micMuted;
  final bool camOff;
  final bool controlsVisible;
  final int callSeconds;
  final ConnectionQuality quality;
  final VideoEffect videoEffect;
  final String? remoteName;
  final String? remoteAvatar;
  final double? rxPacketLossRate;
  final int? avgLatency;
  final bool isPipMode;
  final int? rating;
  final String? ratingFeedback;
  final String? errorMessage;

  VideoCallState({
    this.state = CallState.connecting,
    this.remoteJoined = false,
    this.micMuted = false,
    this.camOff = false,
    this.controlsVisible = true,
    this.callSeconds = 0,
    this.quality = ConnectionQuality.good,
    this.videoEffect = VideoEffect.warmGlow,
    this.remoteName,
    this.remoteAvatar,
    this.rxPacketLossRate,
    this.avgLatency,
    this.isPipMode = false,
    this.rating,
    this.ratingFeedback,
    this.errorMessage,
  });

  VideoCallState copyWith({
    CallState? state,
    bool? remoteJoined,
    bool? micMuted,
    bool? camOff,
    bool? controlsVisible,
    int? callSeconds,
    ConnectionQuality? quality,
    VideoEffect? videoEffect,
    String? remoteName,
    String? remoteAvatar,
    double? rxPacketLossRate,
    int? avgLatency,
    bool? isPipMode,
    int? rating,
    String? ratingFeedback,
    String? errorMessage,
  }) {
    return VideoCallState(
      state: state ?? this.state,
      remoteJoined: remoteJoined ?? this.remoteJoined,
      micMuted: micMuted ?? this.micMuted,
      camOff: camOff ?? this.camOff,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      callSeconds: callSeconds ?? this.callSeconds,
      quality: quality ?? this.quality,
      videoEffect: videoEffect ?? this.videoEffect,
      remoteName: remoteName ?? this.remoteName,
      remoteAvatar: remoteAvatar ?? this.remoteAvatar,
      rxPacketLossRate: rxPacketLossRate ?? this.rxPacketLossRate,
      avgLatency: avgLatency ?? this.avgLatency,
      isPipMode: isPipMode ?? this.isPipMode,
      rating: rating ?? this.rating,
      ratingFeedback: ratingFeedback ?? this.ratingFeedback,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get formattedDuration {
    final minutes = callSeconds ~/ 60;
    final seconds = callSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// How the call screen was opened.
///
/// `callId` is set when the callee answers a ring from a push notification;
/// without it the screen is the caller and starts the call for [matchId].
class VideoCallParams {
  final String matchId;
  final String? callId;
  final String remoteName;
  final String? remoteAvatar;

  VideoCallParams({
    required this.matchId,
    this.callId,
    this.remoteName = 'SawaLove call',
    this.remoteAvatar,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoCallParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          callId == other.callId;

  @override
  int get hashCode => Object.hash(matchId, callId);
}

/// Drives one Agora video call.
///
/// Signalling lives in Postgres (`start_call` / `answer_call` / `end_call`),
/// the channel token comes from the `agora-token` Edge Function, and the ring
/// reaches the callee through the `notify-call` function. Everything degrades
/// to the plain "connecting" state when the build has no `AGORA_APP_ID`.
class VideoCallNotifier extends StateNotifier<VideoCallState> {
  VideoCallNotifier({
    required this.params,
    BackendService? backend,
  })  : _backend = backend ?? BackendService(),
        super(VideoCallState(
          remoteName: params.remoteName,
          remoteAvatar: params.remoteAvatar,
        )) {
    unawaited(_connect());
  }

  final VideoCallParams params;
  final BackendService _backend;

  RtcEngine? _engine;
  VideoViewController? _localController;
  VideoViewController? _remoteController;
  String? _callId;
  Timer? _callTimer;
  Timer? _connectTimer;
  bool _finished = false;

  VideoViewController? get localController => _localController;
  VideoViewController? get remoteController => _remoteController;
  String? get callId => _callId;

  Future<void> _connect() async {
    if (!AgoraConfig.isConfigured) {
      _fail('Video calling is not configured on this build.');
      return;
    }

    // The caller gives up after the ring's TTL so a missed call does not
    // leave the screen spinning forever.
    _connectTimer = Timer(const Duration(seconds: 45), () {
      if (!mounted || state.state == CallState.active) return;
      _fail('No answer.');
      unawaited(hangUp());
    });

    try {
      final incomingCallId = params.callId;
      final call = incomingCallId == null
          ? await _backend.startCall(params.matchId)
          : await _backend.fetchCall(incomingCallId);
      if (!mounted) return;
      if (call == null) {
        _fail('This call has already ended.');
        return;
      }

      final callId = (call['call_id'] ?? call['id'])?.toString() ?? '';
      if (callId.isEmpty) {
        _fail('This call could not be started.');
        return;
      }
      _callId = callId;

      if (incomingCallId == null) {
        // Ring the callee's devices; RTC does not depend on the ring landing.
        unawaited(_backend.notifyIncomingCall(callId));
      } else {
        await _backend.answerCall(callId);
      }

      final credentials = await _backend.fetchAgoraToken(callId);
      if (!mounted) return;
      final appId = credentials['app_id']?.toString() ?? '';
      final channel = (credentials['channel_name'] ?? call['channel_name'])
              ?.toString() ??
          '';
      final token = credentials['token'].toString();
      final rtcUid = (credentials['uid'] as num?)?.toInt() ?? 0;
      if (channel.isEmpty) {
        _fail('This call has no channel.');
        return;
      }

      await _join(
        appId: appId.isEmpty ? AgoraConfig.appId : appId,
        channel: channel,
        token: token,
        rtcUid: rtcUid,
      );
    } catch (e) {
      logger.w('Call setup failed: $e');
      _fail('Could not connect the call.');
    }
  }

  Future<void> _join({
    required String appId,
    required String channel,
    required String token,
    required int rtcUid,
  }) async {
    final engine = createAgoraRtcEngine();
    _engine = engine;

    engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        if (!mounted) return;
        _connectTimer?.cancel();
        _startCallTimer();
        state = state.copyWith(state: CallState.active);
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        if (!mounted) return;
        _remoteController = VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: connection.channelId),
        );
        state = state.copyWith(remoteJoined: true, state: CallState.active);
      },
      onUserOffline: (connection, remoteUid, reason) {
        if (!mounted) return;
        _remoteController = null;
        state = state.copyWith(remoteJoined: false);
      },
      onError: (code, message) => logger.w('Agora error $code: $message'),
      onTokenPrivilegeWillExpire: (connection, expiringToken) =>
          unawaited(_renewToken(engine)),
    ));

    await engine.initialize(RtcEngineContext(appId: appId));
    await engine.enableVideo();
    await engine.enableAudio();
    await engine.startPreview();

    _localController = VideoViewController(
      rtcEngine: engine,
      canvas: const VideoCanvas(uid: 0),
    );
    // Rebuild so the preview picks up the controller.
    if (mounted) state = state.copyWith();

    await engine.joinChannel(
      token: token,
      channelId: channel,
      uid: rtcUid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  Future<void> _renewToken(RtcEngine engine) async {
    final callId = _callId;
    if (callId == null) return;
    try {
      final credentials = await _backend.fetchAgoraToken(callId);
      await engine.renewToken(credentials['token'].toString());
    } catch (e) {
      logger.w('Could not renew the Agora token: $e');
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      state = state.copyWith(callSeconds: state.callSeconds + 1);
    });
  }

  Future<void> toggleMic() async {
    final muted = !state.micMuted;
    state = state.copyWith(
      micMuted: muted,
      state: muted ? CallState.muted : CallState.active,
    );
    await _engine?.muteLocalAudioStream(muted);
  }

  Future<void> toggleCamera() async {
    final off = !state.camOff;
    state = state.copyWith(
      camOff: off,
      state: off ? CallState.cameraOff : CallState.active,
    );
    await _engine?.muteLocalVideoStream(off);
  }

  Future<void> flipCamera() async {
    await _engine?.switchCamera();
  }

  /// Hangs up, tells the other side through `end_call`, and frees the engine.
  Future<void> hangUp({bool declined = false}) async {
    if (_finished) return;
    _finished = true;
    _callTimer?.cancel();
    _connectTimer?.cancel();

    final callId = _callId;
    if (callId != null) {
      try {
        await _backend.endCall(callId, declined: declined);
      } catch (e) {
        // The call may already be over server-side; still release the engine.
        logger.w('Could not end the call: $e');
      }
    }

    await _releaseEngine();
    if (mounted) state = state.copyWith(state: CallState.summary);
  }

  Future<void> _releaseEngine() async {
    final engine = _engine;
    _engine = null;
    _localController = null;
    _remoteController = null;
    if (engine == null) return;
    try {
      await engine.leaveChannel();
      await engine.release();
    } catch (e) {
      logger.w('Could not release the Agora engine: $e');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    state = state.copyWith(state: CallState.ended, errorMessage: message);
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _connectTimer?.cancel();
    final engine = _engine;
    _engine = null;
    if (engine != null) {
      unawaited(() async {
        try {
          await engine.leaveChannel();
          await engine.release();
        } catch (e) {
          logger.w('Could not release the Agora engine: $e');
        }
      }());
    }
    super.dispose();
  }
}

// Provider
final videoCallProvider = StateNotifierProvider.family<VideoCallNotifier,
    VideoCallState, VideoCallParams>((ref, params) {
  return VideoCallNotifier(params: params);
});
