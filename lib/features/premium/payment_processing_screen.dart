import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class PaymentProcessingScreen extends StatefulWidget {
  const PaymentProcessingScreen({super.key});

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _status = 'Sending to MTN MoMo...';
  final String _phone = '6 77 123 456';
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(_pulseController);
    _pulseController.repeat(reverse: true);

    // Simulate polling
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final statuses = [
        'Sending to MTN MoMo...',
        'Awaiting payment confirmation...',
        'Verifying transaction XAF 5,000...',
        'Payment received!',
      ];
      if (mounted) {
        setState(() {
          _status = statuses[min(Random().nextInt(4), statuses.length - 1)];
        });
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loader
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [SawaLoveTheme.primary, SawaLoveTheme.primaryContainer],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              Text(
                'Gold Subscription',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text('XAF 5,000 / month', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 32),
              // Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        _status,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Phone number
                      Row(
                        children: [
                          const Icon(Icons.phone, color: SawaLoveTheme.tertiary),
                          const SizedBox(width: 12),
                          Text(_phone),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Check your phone for payment prompt',
                        style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Action
              ElevatedButton(
                onPressed: () {
                  // Simulate retry or cancel
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Something wrong?'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

