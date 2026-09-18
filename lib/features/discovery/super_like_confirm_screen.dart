import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class SuperLikeConfirmScreen extends StatelessWidget {
  const SuperLikeConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  SawaLoveTheme.surface.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Super like star
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6EA9), Color(0xFFB30065)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Super Like',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SawaLoveTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Stand out! They\'ll see you first and get a notification.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                // Quota badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [SawaLoveTheme.primary.withValues(alpha: 0.2), SawaLoveTheme.primaryContainer.withValues(alpha: 0.2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: SawaLoveTheme.primary),
                          SizedBox(width: 6),
                          Text(
                            '3/5 daily',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Regular Like'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Track super like
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Super Liked! They\'ll be notified.'),
                              backgroundColor: Color(0xFFB30065),
                            ),
                          );
                          context.pop();
                          // Trigger match logic in discovery
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SawaLoveTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: const Text(
                          'Super Like',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

