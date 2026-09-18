import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';

class PoolCounterCard extends StatelessWidget {
  final int count;
  final double fraction;
  final String? subLabel;
  final String? warningMessage;
  final bool showWarningBanner;

  const PoolCounterCard({
    super.key,
    required this.count,
    required this.fraction,
    this.subLabel,
    this.warningMessage,
    this.showWarningBanner = false,
  });

  Color get _poolColor {
    if (count > 500) return SawaLoveTheme.tertiary;
    if (count > 80) return SawaLoveTheme.primary;
    return SawaLoveTheme.errorColor.withValues(alpha: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _poolColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Warning banner
          if (showWarningBanner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SawaLoveTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: SawaLoveTheme.errorColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warningMessage ?? 'Your filters are very narrow. Try widening to see more people.',
                      style: const TextStyle(
                        color: SawaLoveTheme.errorColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (showWarningBanner) const SizedBox(height: 16),

          // Main pool number
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              count.toString(),
              key: ValueKey(count),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: _poolColor,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subLabel ?? 'people match your preferences',
            style: TextStyle(
              color: SawaLoveTheme.onSurface.withValues(alpha: 0.6),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: SawaLoveTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_poolColor.withValues(alpha: 0.4), _poolColor],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

