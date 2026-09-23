import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/theme/theme.dart';
import '../providers/voice_recorder_provider.dart';
import '../providers/live_amplitude_provider.dart';

class RecordingOverlay extends ConsumerStatefulWidget {
  final String conversationId;
  const RecordingOverlay({super.key, required this.conversationId});

  @override
  ConsumerState<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends ConsumerState<RecordingOverlay> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  double _dragDx = 0.0;
  int _timerSeconds = 0;
  late Timer _uiTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _timerSeconds++);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceRecorderProvider.notifier).startRecording(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _uiTimer.cancel();
    super.dispose();
  }

  String get _timerText {
    final mins = _timerSeconds ~/ 60;
    final secs = _timerSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool get _showCancel => _dragDx < -5;

  @override
  Widget build(BuildContext context) {
    final recorderState = ref.watch(voiceRecorderProvider);
    final liveAmp = ref.watch(liveAmplitudeProvider);

    if (recorderState == RecorderState.idle) {
      Navigator.pop(context);
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Drag gesture
          GestureDetector(
            onHorizontalDragUpdate: (details) => setState(() => _dragDx += details.delta.dx),
            onHorizontalDragEnd: (details) {
              if (_dragDx < -50 || details.primaryVelocity! < -200) {
                ref.read(voiceRecorderProvider.notifier).cancel();
                Navigator.pop(context);
              } else {
                setState(() => _dragDx = 0.0);
              }
            },
            child: SlideTransition(
              position: Tween<Offset>(begin: Offset.zero, end: const Offset(-0.1, 0)).animate(_slideController),
              child: Container(color: Colors.transparent),
            ),
          ),
          // UI
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Countdown bar if near max
                  if (_timerSeconds > 55)
                    Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: SawaLoveTheme.errorColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0 - (_timerSeconds - 55) / 5,
                        child: Container(color: SawaLoveTheme.errorColor),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Pulsing dot + label
                  ScaleTransition(
                    scale: _pulseController,
                    child: Container(
                      width: 64, height: 64,
                      decoration: const BoxDecoration(color: SawaLoveTheme.errorColor, shape: BoxShape.circle),
                      child: const Icon(Icons.mic, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Recording · Enregistrement', style: SawaLoveTheme.headlineSmall?.copyWith(color: SawaLoveTheme.errorColor)),
                  const SizedBox(height: 16),
                  // Live waveform
                  SizedBox(
                    height: 40,
                    child: CustomPaint(
                      painter: LiveWaveformPainter(liveAmp),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(_timerText, style: SawaLoveTheme.headlineMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 64),
                  // Cancel / Send (send disabled if <1s)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: _showCancel ? () {
                          ref.read(voiceRecorderProvider.notifier).cancel();
                          Navigator.pop(context);
                        } : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            _showCancel ? '← Release to cancel' : 'Slide ← to cancel',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _timerSeconds > 1 ? () {
                          ref.read(voiceRecorderProvider.notifier).stopAndSend(widget.conversationId);
                          Navigator.pop(context);
                        } : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: SawaLoveTheme.success,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text('Send', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveWaveformPainter extends CustomPainter {
  final double amp;

  LiveWaveformPainter(this.amp);

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 20;
    const barWidth = 4.0;
    const gap = 2.0;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final progress = i / barCount;
      final height = (size.height * 0.6 * progress + size.height * 0.2 * amp).clamp(4.0, size.height * 0.8);
      final paint = Paint()..color = SawaLoveTheme.errorColor.withValues(alpha: 0.8 - progress * 0.4);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * (barWidth + gap), centerY - height / 2, barWidth, height),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LiveWaveformPainter oldDelegate) => oldDelegate.amp != amp;
}

