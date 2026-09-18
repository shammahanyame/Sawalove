import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_settings_provider.dart';

/// EN/FR toggle that actually changes the app locale (persisted via
/// [appSettingsProvider]). Screens no longer need to keep a local
/// `currentLang` string that never affected the rest of the app.
class BilingualToggle extends ConsumerWidget {
  /// Optional explicit override; when null the persisted app locale drives it.
  final String? currentLang;
  final ValueChanged<String>? onLangChanged;

  const BilingualToggle({
    super.key,
    this.currentLang,
    this.onLangChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final active = currentLang ?? settings.locale.languageCode;

    void change(String lang) {
      if (onLangChanged != null) {
        onLangChanged!(lang);
        return;
      }
      ref.read(appSettingsProvider.notifier).setLocale(Locale(lang));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: 'EN',
            isSelected: active.startsWith('en'),
            onTap: () => change('en'),
          ),
          _ToggleButton(
            label: 'FR',
            isSelected: active.startsWith('fr'),
            onTap: () => change('fr'),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Language $label',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
