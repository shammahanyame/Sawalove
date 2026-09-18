// lib/features/onboarding/widgets/photo_progress_bar.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PhotoProgressBar extends StatelessWidget {
  final int count;

  const PhotoProgressBar({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final double fraction = count / 6;
    final bool isComplete = count >= 6;
    final Color fillColor = isComplete ? const Color(0xFF1D9E75) : SawaLoveTheme.primary;

    String label;
    String sublabel;

    if (count < 2) {
      label = '$count / 2 min';
      sublabel = 'Add ${2 - count} more to continue';
    } else if (count < 4) {
      label = '$count / 6 max';
      sublabel = 'Tip: Profiles with 4+ photos get 3× more likes';
    } else if (count < 6) {
      label = '$count / 6 max';
      sublabel = 'Looking great! Add ${6 - count} more if you want';
    } else {
      label = '6 / 6 max';
      sublabel = 'Perfect! Your photos are ready';
    }

    return Semantics(
      label: 'Photo progress: $count of 2 minimum, $count of 6 maximum added.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: SawaLoveTheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(fillColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SawaLoveTheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                sublabel,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: SawaLoveTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

