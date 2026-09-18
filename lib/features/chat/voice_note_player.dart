import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class VoiceNotePlayer extends StatefulWidget {
  const VoiceNotePlayer({super.key});

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  double _progress = 0.3; // 30% played
  bool _isPlaying = true;
  final int _duration = 12; // 12 seconds
  List<double> _waveformData = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _generateWaveform();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1.0) {
            _progress = 0.0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _generateWaveform() {
    _waveformData = List.generate(50, (index) => Random().nextDouble() * 0.8 + 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: SawaLoveTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Avatar
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Amaka N.', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                // Waveform
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        SizedBox(
                          height: 20,
                          child: CustomPaint(
                            painter: WaveformPainter(_waveformData, _progress),
                          ),
                        ),
                        Align(
                          alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, _progress)!,
                          child: SizedBox(
                            width: 4,
                            height: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                color: SawaLoveTheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Text('${(_progress * _duration).round()} / $_duration'),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = !_isPlaying;
                if (_isPlaying) {
                  _waveController.forward();
                } else {
                  _waveController.stop();
                }
              });
            },
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _waveController,
              color: SawaLoveTheme.primary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> data;
  final double progress;

  WaveformPainter(this.data, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SawaLoveTheme.primary.withValues(alpha: 0.6)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    final barWidth = size.width / data.length;
    for (int i = 0; i < data.length; i++) {
      final barHeight = size.height * data[i];
      canvas.drawLine(
        Offset(i * barWidth, size.height / 2 + barHeight / 2),
        Offset(i * barWidth, size.height / 2 - barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Usage in chat bubble:
// VoiceNotePlayer()

