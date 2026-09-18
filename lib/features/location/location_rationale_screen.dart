import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class LocationRationaleScreen extends StatelessWidget {
  const LocationRationaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SawaLoveTheme.primary, SawaLoveTheme.primaryContainer],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Location Access',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // English
              if (Localizations.localeOf(context).languageCode == 'en') ...[
                Text(
                  'Find love nearby',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'We use approximate city/region only (never exact GPS). '
                  'Show Douala girls 5km away, Yaoundé guys near Centre. '
                  'Your privacy protected.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // French
                Text(
                  'Trouvez l\'amour près de chez vous',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'On utilise seulement ville/région approximative (jamais GPS exact). '
                  'Filles Douala 5km, gars Yaoundé près Centre. '
                  'Votre vie privée protégée.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              // Benefits
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _benefit(Icons.near_me, 'People 1-50km away'),
                      _benefit(Icons.privacy_tip, 'City only - no tracking'),
                      _benefit(Icons.public, 'Cameroon regions optimized'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/location-manual'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Request permission
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location permission requested')),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SawaLoveTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Allow Location'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SawaLoveTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: SawaLoveTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

