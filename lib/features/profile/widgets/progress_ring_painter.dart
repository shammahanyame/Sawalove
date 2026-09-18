// lib/features/profile/widgets/progress_ring_painter.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color strokeColor;
  final Color backgroundColor;
  final double strokeWidth;
  final double ringSize;

  ProgressRingPainter({
    required this.progress,
    this.strokeColor = const Color(0xFFB30065),
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.strokeWidth = 6.0,
    this.ringSize = 72.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      backgroundPaint,
    );

    // Progress ring
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          strokeColor.withValues(alpha: 0.8),
          strokeColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
