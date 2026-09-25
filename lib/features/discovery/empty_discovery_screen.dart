import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class EmptyDiscoveryScreen extends StatelessWidget {
  const EmptyDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state illustration
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SawaLoveTheme.primary.withValues(alpha: 0.1), SawaLoveTheme.primaryContainer.withValues(alpha: 0.1)],
                  ),
                  borderRadius: BorderRadius.circular(80),
                ),
                child: const Icon(
                  Icons.search_off,
                  size: 64,
                  color: SawaLoveTheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No more profiles nearby',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Try widening your search or complete your profile to see more matches.',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: SawaLoveTheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              // CTA buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/discover/filters'),
                      icon: const Icon(Icons.tune),
                      label: const Text('Widen Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SawaLoveTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/profile/complete'),
                    icon: const Icon(Icons.person),
                    label: const Text('Improve Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: SawaLoveTheme.outlineVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Stats',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statCard('Likes Sent', '24'),
                        _statCard('Views', '156'),
                        _statCard('Matches', '3'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: SawaLoveTheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

