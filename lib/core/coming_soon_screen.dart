import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/theme.dart';

/// Replaces unfinished feature screens in release builds so the app never
/// shows a feature that cannot actually do what it appears to do.
///
/// Bilingual (EN/FR) because the app ships with both languages.
class ComingSoonScreen extends StatelessWidget {
  final String feature;
  final String? featureFr;

  const ComingSoonScreen({super.key, required this.feature, this.featureFr});

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    final title = isFrench
        ? (featureFr ?? '$feature arrive bientôt')
        : '$feature is coming soon';

    return Scaffold(
      appBar: AppBar(title: const Text('SawaLove')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SawaLoveTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 64,
                  color: SawaLoveTheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isFrench
                    ? 'Nous mettons la touche finale pour que cette '
                        'fonctionnalité fonctionne de manière fiable pour '
                        'tout le monde. En attendant, vous pouvez continuer à '
                        'découvrir des profils et à compléter le vôtre.'
                    : 'We are putting the finishing touches on it so it works '
                        'reliably for everyone. Meanwhile, you can keep '
                        'discovering profiles and set up your own.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SawaLoveTheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/home/discover'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SawaLoveTheme.primary,
                  foregroundColor: SawaLoveTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  isFrench ? 'Retour à la découverte' : 'Back to Discover',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
