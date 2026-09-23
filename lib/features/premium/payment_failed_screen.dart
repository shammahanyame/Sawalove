import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SawaLoveTheme.surface,
      appBar: AppBar(
        title: const Text('Payment Failed'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: SawaLoveTheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error,
                  color: SawaLoveTheme.errorColor,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Payment Failed',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Your payment could not be processed. Check your phone balance or try another method.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 48),
              // Common errors
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error_outline, color: SawaLoveTheme.warning),
                          SizedBox(width: 12),
                          Text('Common issues', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _errorItem(context, 'Insufficient balance', 'Add airtime'),
                      _errorItem(context, 'Wrong PIN', 'Check MoMo PIN'),
                      _errorItem(context, 'Network error', 'Try WiFi/4G'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // CTAs
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/premium/plans'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SawaLoveTheme.primary,
                      ),
                      child: const Text('Retry Payment'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Change Plan'),
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

  Widget _errorItem(BuildContext context, String issue, String solution) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: SawaLoveTheme.warning),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: '$issue: ', style: const TextStyle(fontWeight: FontWeight.w500)),
                  TextSpan(text: solution, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

