import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/theme/theme.dart';

class FilterPillChip extends ConsumerWidget {
  final String label;
  final String filterKey;
  final VoidCallback onRemove;

  const FilterPillChip({
    super.key,
    required this.label,
    required this.filterKey,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(filterKey),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: SawaLoveTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline,
          color: SawaLoveTheme.errorColor,
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SawaLoveTheme.primary,
              SawaLoveTheme.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.close,
              color: Colors.white.withValues(alpha: 0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

