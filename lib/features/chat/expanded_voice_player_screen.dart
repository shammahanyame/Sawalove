import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/features/chat/providers/voice_player_provider.dart';
import 'package:sawalove/features/chat/widgets/voice_note_bubble.dart'; // reuse painter
import 'package:sawalove/shared/models/voice_message.dart';

class ExpandedVoicePlayerScreen extends ConsumerStatefulWidget {
  final VoiceMessage message;
  final String conversationId;
  const ExpandedVoicePlayerScreen({super.key, required this.message, required this.conversationId});

  @override
  ConsumerState<ExpandedVoicePlayerScreen> createState() => _ExpandedVoicePlayerScreenState();
}

class _ExpandedVoicePlayerScreenState extends ConsumerState<ExpandedVoicePlayerScreen> with TickerProviderStateMixin {
  late AnimationController _dismissController;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voicePlayerProvider(widget.message.id).notifier).play(widget.message.audioUrl, conversationId: widget.conversationId);
    });
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(voicePlayerProvider(widget.message.id));
    final amplitudes = widget.message.amplitudeData.isEmpty ? widget.message.fallbackAmplitudeData : widget.message.amplitudeData;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Drag handle
            GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 5) {
                  _dismissController.forward().then((_) => context.pop());
                }
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  const CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108755-2616b612b786'),
                  ),
                  const SizedBox(height: 32),
                  Text('Voice message', style: SawaLoveTheme.headlineMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 16),
                  // Large waveform
                  SizedBox(
                    height: 64,
                    child: GestureDetector(
                      onTapDown: (details) {
                        final fraction = details.localPosition.dx / context.size!.width;
                        ref.read(voicePlayerProvider(widget.message.id).notifier).seek(fraction);
                      },
                      child: CustomPaint(
                        painter: WaveformPainter(amplitudes, playerState.progress, false, isPlaying: playerState.isPlaying), // incoming style
                        size: Size.infinite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(widget.message.durationDisplay, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 48),
                  // Speed chips
                  Wrap(
                    spacing: 8,
                    children: [1.0, 1.5, 2.0].map((speed) => ChoiceChip(
                      label: Text('${speed}x'),
                      selected: (playerState.speed - speed).abs() < 0.01,
                      onSelected: (_) => ref.read(voicePlayerProvider(widget.message.id).notifier).setSpeed(speed),
                      selectedColor: SawaLoveTheme.primary.withValues(alpha: 0.2),
                    )).toList(),
                  ),
                  const SizedBox(height: 48),
                  // Skip buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 48,
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed: () {
                          final newPos = (playerState.position - const Duration(seconds: 5)).inMilliseconds.clamp(0, playerState.duration.inMilliseconds);
                          ref.read(voicePlayerProvider(widget.message.id).notifier).seek(newPos / playerState.duration.inMilliseconds);
                        },
                      ),
                      GestureDetector(
                        onTap: () => ref.read(voicePlayerProvider(widget.message.id).notifier).toggle(),
                        child: Icon(
                          playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                      IconButton(
                        iconSize: 48,
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        onPressed: () {
                          final newPos = (playerState.position + const Duration(seconds: 5)).inMilliseconds.clamp(0, playerState.duration.inMilliseconds);
                          ref.read(voicePlayerProvider(widget.message.id).notifier).seek(newPos / playerState.duration.inMilliseconds);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Actions
                  Row(
                    children: [
                      Expanded(child: TextButton(onPressed: () => context.pop(), child: const Text('Delete', style: TextStyle(color: Colors.white70)))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(onPressed: () => context.pop(), child: const Text('Reply'))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reuse WaveformPainter from bubble

