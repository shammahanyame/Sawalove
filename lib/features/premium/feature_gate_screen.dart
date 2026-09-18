import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/l10n/app_localizations.dart';

class FeatureGateScreen extends StatelessWidget {
  final String reason;
  final String recipientName;
  const FeatureGateScreen({
    super.key,
    this.reason = 'premium',
    this.recipientName = 'members',
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        final l10n = AppLocalizations.of(context);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Icon(
                  Icons.chat_outlined,
                  color: SawaLoveTheme.primary,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    l10n.messageAnyone,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Send a direct message to $recipientName',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Free accounts can only message mutual matches. Upgrade to Premium to message anyone.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 48),
                // Benefits
                Column(
                  children: [
                    _benefitItem(Icons.chat, 'Message anyone without matching'),
                    _benefitItem(Icons.flash_on, 'Unlimited Super Likes'),
                    _benefitItem(Icons.insights, 'See who likes you'),
                    _benefitItem(Icons.replay, 'Unlimited Rewinds'),
                  ],
                ),
                const SizedBox(height: 32),
                // CTAs
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          context.go('/premium/plans');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SawaLoveTheme.primary,
                        ),
                        icon: const Icon(Icons.star, color: Colors.white),
                        label: const Text('Upgrade to Gold'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton.icon(
                        onPressed: () {
                          context.pop();
                          // Trigger like action
                          // ref.read(likeProvider.notifier).like(recipientUid);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        icon: const Icon(Icons.favorite_border),
                        label: Text('Like $recipientName instead'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _benefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SawaLoveTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: SawaLoveTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

