import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/intent_picker_notifier.dart';
import 'package:go_router/go_router.dart';

class IntentPickerScreen extends ConsumerWidget {
  const IntentPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intentState = ref.watch(intentPickerProvider);
    final isValid = intentState.isValid;

    return Scaffold(
      appBar: AppBar(title: const Text('What are you looking for?')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Friendship / Rencontres amicales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _IntentCard(
                  id: 'friendship',
                  title: 'Friendship / Amitié',
                  subtitle: 'Most wholesome',
                  color: const Color(0xFF1D9E75),
                  containerColor: const Color(0xFFE8F8EF),
                  selected: intentState.selectedIntents.contains('friendship'),
                  onTap: () => ref.read(intentPickerProvider.notifier).toggle('friendship'),
                ),
                _IntentCard(
                  id: 'casual',
                  title: 'Casual dating / Rencontres légères',
                  subtitle: 'Most popular',
                  color: const Color(0xFFB30065),
                  containerColor: const Color(0xFFFFE0EA),
                  selected: intentState.selectedIntents.contains('casual'),
                  onTap: () => ref.read(intentPickerProvider.notifier).toggle('casual'),
                ),
                _IntentCard(
                  id: 'serious',
                  title: 'Serious relationship / Relation sérieuse',
                  subtitle: 'Premium',
                  color: const Color(0xFF8329C8),
                  containerColor: const Color(0xFFE7C5FF),
                  selected: intentState.selectedIntents.contains('serious'),
                  onTap: () => ref.read(intentPickerProvider.notifier).toggle('serious'),
                ),
                _IntentCard(
                  id: 'networking',
                  title: 'Networking / Réseautage',
                  subtitle: 'Diaspora favourite',
                  color: const Color(0xFF00647C),
                  containerColor: const Color(0xFFE1F5EE),
                  selected: intentState.selectedIntents.contains('networking'),
                  onTap: () => ref.read(intentPickerProvider.notifier).toggle('networking'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (intentState.selectedIntents.isNotEmpty) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Who can see your intent?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: [
                        _VisibilityChip(
                          label: 'Everyone / Tout le monde',
                          value: 'everyone',
                          selected: intentState.visibilityMode == 'everyone',
                          onTap: () => ref.read(intentPickerProvider.notifier).setVisibility('everyone'),
                        ),
                        _VisibilityChip(
                          label: 'Matches only / Mes matchs seulement',
                          value: 'matches',
                          selected: intentState.visibilityMode == 'matches',
                          onTap: () => ref.read(intentPickerProvider.notifier).setVisibility('matches'),
                        ),
                        _VisibilityChip(
                          label: 'Keep private / Garder privé',
                          value: 'private',
                          selected: intentState.visibilityMode == 'private',
                          onTap: () => ref.read(intentPickerProvider.notifier).setVisibility('private'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      ref.read(intentPickerProvider.notifier).skip();
                      context.go('/onboarding/religion');
                    },
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isValid ? () => ref.read(intentPickerProvider.notifier).save(context) : null,
                    child: Text(intentState.selectedIntents.length > 1 
                      ? "We'll show you people open to all of these"
                      : 'Continue'),
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

class _IntentCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final Color containerColor;
  final bool selected;
  final VoidCallback onTap;

  const _IntentCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.containerColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title, $subtitle. ${selected ? "Selected" : "Not selected"}. Double tap to ${selected ? "deselect" : "select"}.',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
            color: selected ? containerColor : Colors.white,
            boxShadow: selected 
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 16)]
              : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selected ? Icons.check : null,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisibilityChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label — ${selected ? "currently selected" : "tap to select"}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: selected ? SawaLoveTheme.surfaceContainerHigh : Colors.transparent,
            border: Border.all(color: SawaLoveTheme.outlineVariant),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

