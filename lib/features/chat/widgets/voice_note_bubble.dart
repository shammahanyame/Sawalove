import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/features/chat/providers/voice_player_provider.dart';
import 'package:sawalove/shared/models/voice_message.dart';

class VoiceNoteBubble extends ConsumerWidget {
  final VoiceMessage message;
  final bool isOutgoing;

  const VoiceNoteBubble({
    super.key,
    required this.message,
    required this.isOutgoing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(voicePlayerProvider(message.id));
    final amplitudes = message.amplitudeData.isEmpty ? message.fallbackAmplitudeData : message.amplitudeData;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOutgoing ? SawaLoveTheme.primaryContainer : SawaLoveTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOutgoing) ...[
            const CircleAvatar(radius: 16, backgroundColor: Colors.transparent, child: Icon(Icons.person, size: 20)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(voicePlayerProvider(message.id).notifier).toggle(),
                      child: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: isOutgoing ? Colors.white : SawaLoveTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      message.durationDisplay,
                      style: TextStyle(
                        color: isOutgoing ? Colors.white.withValues(alpha: 0.9) : SawaLoveTheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTapDown: (details) {
                    final fraction = details.localPosition.dx / context.size!.width;
                    ref.read(voicePlayerProvider(message.id).notifier).seek(fraction);
                  },
                  child: SizedBox(
                    height: 26,
                    child: CustomPaint(
                      painter: WaveformPainter(
                        amplitudes,
                        playerState.progress,
                        isOutgoing,
                        isPlaying: playerState.isPlaying,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isOutgoing) const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final bool isOutgoing;
  final bool isPlaying;

  WaveformPainter(this.data, this.progress, this.isOutgoing, {this.isPlaying = false});

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 3.0;
    const gap = 2.0;
    const minHeight = 6.0;
    const maxHeight = 26.0;

    final barCount = data.length;
    final totalWidth = barCount * barWidth + (barCount - 1) * gap;
    final startX = (size.width - totalWidth) / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = startX + i * (barWidth + gap);
      final height = minHeight + (maxHeight - minHeight) * data[i];
      final isPlayed = i / barCount <= progress;
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.fill;

      if (isOutgoing) {
        paint.color = isPlayed ? Colors.white.withValues(alpha: isPlaying ? 0.9 : 0.4) : Colors.white.withValues(alpha: 0.4);
      } else {
        paint.color = isPlayed ? const Color(0xFFB30065) : const Color(0xFFD89CB4);
      }

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - height / 2, barWidth, height),
        const Radius.circular(1.0),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

