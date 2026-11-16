import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';

import 'providers/video_call_provider.dart';

/// Agora-backed video call screen.
///
/// Opened as the caller with `matchId` (the provider starts the ring) or as the
/// callee with `callId` from the push payload (the provider answers it).
class VideoCallScreen extends ConsumerWidget {
  final String? matchId;
  final String? callId;
  final String remoteName;
  final String? remoteAvatar;

  const VideoCallScreen({
    super.key,
    this.matchId,
    this.callId,
    this.remoteName = 'SawaLove call',
    this.remoteAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = VideoCallParams(
      matchId: matchId ?? '',
      callId: callId,
      remoteName: remoteName,
      remoteAvatar: remoteAvatar,
    );
    final provider = videoCallProvider(params);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final remote = notifier.remoteController;
    final local = notifier.localController;
    final finished =
        state.state == CallState.summary || state.state == CallState.ended;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!finished && remote != null && state.remoteJoined)
              AgoraVideoView(controller: remote)
            else
              Container(
                color: SawaLoveTheme.darkSurfaceContainerHigh,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        finished ? Icons.call_end : Icons.videocam_off,
                        color: Colors.white54,
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          finished
                              ? (state.errorMessage ?? 'Call ended')
                              : (state.errorMessage ?? 'Connecting…'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (!finished) ...[
                        const SizedBox(height: 6),
                        Text(
                          state.remoteName ?? remoteName,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            // Self preview, top-right, while the camera is on.
            if (!finished && local != null && !state.camOff)
              Positioned(
                top: 88,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 120,
                    height: 160,
                    child: AgoraVideoView(controller: local),
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => _close(context, notifier),
                    ),
                    Column(
                      children: [
                        Text(
                          state.remoteName ?? remoteName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          state.formattedDuration,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            if (!finished)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _controlButton(
                        icon: state.micMuted ? Icons.mic_off : Icons.mic,
                        isActive: !state.micMuted,
                        onTap: notifier.toggleMic,
                      ),
                      _controlButton(
                        icon: Icons.switch_video,
                        isActive: true,
                        onTap: notifier.flipCamera,
                      ),
                      GestureDetector(
                        onTap: () => _close(context, notifier),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: SawaLoveTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      _controlButton(
                        icon: state.camOff
                            ? Icons.videocam_off
                            : Icons.videocam,
                        isActive: !state.camOff,
                        onTap: notifier.toggleCamera,
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
              ),
            if (finished)
              Positioned(
                left: 24,
                right: 24,
                bottom: 32,
                child: ElevatedButton(
                  onPressed: () => _close(context, notifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SawaLoveTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Done'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _close(BuildContext context, VideoCallNotifier notifier) {
    unawaited(notifier.hangUp());
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/chat');
    }
  }

  Widget _controlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white54,
        ),
      ),
    );
  }
}
