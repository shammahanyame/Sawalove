import 'package:flutter/material.dart';
import 'package:sawalove/shared/models/quota_model.dart';

class QuotaDots extends StatelessWidget {
  final QuotaState quota;
  final bool showPreview;

  const QuotaDots({
    super.key,
    required this.quota,
    this.showPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = quota.isPremium ? 15 : 5;
    final used = quota.superLikesUsed;
    final remaining = quota.superLikesRemaining;

    return Semantics(
      label: 'Super Like quota: $used used, $remaining remaining today.',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          Color color;
          if (index < used) {
            // Used dot — magenta
            color = const Color(0xFFB30065);
          } else if (showPreview && index == used) {
            // About to use — purple preview
            color = const Color(0xFF8329C8);
          } else {
            // Remaining — muted pink
            color = const Color(0xFFFFD1E1);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 24,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

