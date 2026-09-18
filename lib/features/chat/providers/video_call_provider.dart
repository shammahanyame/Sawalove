import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
  }

  String get formattedDuration {
    final minutes = callSeconds ~/ 60;
    final seconds = callSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Video call params class
class VideoCallParams {
  final String matchId;
  final String remoteName;
  final String? remoteAvatar;

  VideoCallParams({
    required this.matchId,
    required this.remoteName,
    this.remoteAvatar,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoCallParams &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

// Video call notifier - simplified for UI development
// TODO: Add real Agora integration when types are fixed
class VideoCallNotifier extends StateNotifier<VideoCallState> {
  Timer? _callTimer;
  Timer? _hideControlsTimer;
  Timer? _reconnectTimer;

  VideoCallNotifier({
    required String matchId,
    required String remoteName,
    String? remoteAvatar,
  }) : super(VideoCallState(
    remoteName: remoteName,
    remoteAvatar: remoteAvatar,
  )) {
    _startConnecting();
  }

  void _startConnecting() {
    // Simulate connection delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        state = state.copyWith(
          remoteJoined: true,
          state: CallState.active,
        );
        _startCallTimer();
      }
    });
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        state = state.copyWith(callSeconds: state.callSeconds + 1);
      }
    });
  }

  void toggleMic() {
    final newMuted = !state.micMuted;
    state = state.copyWith(
      micMuted: newMuted,
      state: newMuted ? CallState.muted : CallState.active,
    );
  }

  void toggleCamera() {
    final newCamOff = !state.camOff;
    state = state.copyWith(
      camOff: newCamOff,
      state: newCamOff ? CallState.cameraOff : CallState.active,
    );
  }

  Future<void> flipCamera() async {
    // Would call _engine.switchCamera() in real implementation
  }

  Future<void> setVideoEffect(VideoEffect effect) async {
    state = state.copyWith(videoEffect: effect);
  }

  void toggleControls() {
    _hideControlsTimer?.cancel();
    state = state.copyWith(controlsVisible: true);
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        state = state.copyWith(controlsVisible: false);
      }
    });
  }

  void enterPipMode() {
    state = state.copyWith(isPipMode: true);
  }

  void exitPipMode() {
    state = state.copyWith(isPipMode: false);
  }

  void setRating(int stars) {
    state = state.copyWith(rating: stars);
  }

  void setRatingFeedback(String feedback) {
    state = state.copyWith(ratingFeedback: feedback);
  }

  void endCall() {
    _callTimer?.cancel();
    state = state.copyWith(state: CallState.summary);
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _hideControlsTimer?.cancel();
    _reconnectTimer?.cancel();
    super.dispose();
  }
}

// Provider
final videoCallProvider = StateNotifierProvider.family<VideoCallNotifier, VideoCallState, VideoCallParams>((ref, params) {
  return VideoCallNotifier(
    matchId: params.matchId,
    remoteName: params.remoteName,
    remoteAvatar: params.remoteAvatar,
  );
});
