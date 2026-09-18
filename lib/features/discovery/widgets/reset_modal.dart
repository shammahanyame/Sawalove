import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';

class ResetConfirmModal extends StatelessWidget {
  final int activeFilterCount;
  final VoidCallback onConfirmReset;

  const ResetConfirmModal({
    super.key,
    required this.activeFilterCount,
    required this.onConfirmReset,
  });

  static void show({
    required BuildContext context,
    required int activeFilterCount,
    required VoidCallback onConfirmReset,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResetConfirmModal(
        activeFilterCount: activeFilterCount,
        onConfirmReset: onConfirmReset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_alt_off,
              size: 64,
              color: SawaLoveTheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Reset all filters?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This will clear all ${activeFilterCount > 1 ? "$activeFilterCount filters" : "filter"} and show everyone nearby.',
              style: const TextStyle(
                color: SawaLoveTheme.onSurfaceVariant,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Go back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirmReset();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SawaLoveTheme.errorColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Reset all',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

