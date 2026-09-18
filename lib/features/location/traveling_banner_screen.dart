import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TravelingBannerScreen extends StatelessWidget {
  const TravelingBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB30065), Color(0xFFFF6EA9)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Travel icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.travel_explore,
                    size: 64,
                    color: Color(0xFFB30065),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'You\'re traveling!',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Yaoundé!\nMeet locals who love Centre region.',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Disable travel mode
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Travel banner hidden')),
                          );
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Hide'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Go to local discovery
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Showing Yaoundé locals')),
                          );
                          context.go('/explore');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFB30065),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Find Locals'),
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

