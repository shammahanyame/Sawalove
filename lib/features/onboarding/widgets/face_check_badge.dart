// lib/features/onboarding/widgets/face_check_badge.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

enum FaceCheckType { detected, checking, failed }

class FaceCheckBadge extends StatelessWidget {
  final FaceCheckType type;

  const FaceCheckBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case FaceCheckType.detected:
        return _buildPill(
          color: const Color(0xFF1D9E75),
          icon: Icons.check,
          label: 'Face detected',
        );
      case FaceCheckType.checking:
        return _buildPill(
          color: Colors.amber.shade700,
          icon: Icons.access_time,
          label: 'Checking…',
        );
      case FaceCheckType.failed:
        return _buildPill(
          color: SawaLoveTheme.errorColor,
          icon: Icons.close,
          label: 'No face found',
        );
    }
  }

  Widget _buildPill({required Color color, required IconData icon, required String label}) {
    return Semantics(
      hidden: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

