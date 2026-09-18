import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AccountSuspendedScreen extends StatelessWidget {
  const AccountSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE91E63), Color(0xFFB71C1C)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Warning icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block,
                    size: 80,
                    color: Color(0xFFB71C1C),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Account Suspended',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your account has been temporarily suspended for violating our Community Guidelines.',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFFF9800)),
                        SizedBox(height: 16),
                        Text(
                          'Suspension Reason',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Multiple reports for inappropriate content.\n\nDetails: Photos violating nudity policy.',
                          style: TextStyle(height: 1.5),
                        ),
                        SizedBox(height: 24),
                        Text('Review period: 7 days'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.gavel),
                    label: const Text('Appeal Suspension'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: () => context.go('/safety/moderation-appeal'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/profile/contact-support'),
                  child: const Text('Contact Support', style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

