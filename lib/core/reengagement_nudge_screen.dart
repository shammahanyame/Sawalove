import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class ReengagementNudgeScreen extends StatelessWidget {
  const ReengagementNudgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                // Welcome back icon
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration,
                    size: 80,
                    color: Color(0xFF667eea),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We missed you! Here are 10 free Super Likes to catch up on new matches.',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('25', 'New matches'),
                    _buildStatCard('8', 'Messages'),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // Claim bonus
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('10 Super Likes claimed! 🎉')),
                      );
                      context.go('/discovery');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: const Text('Claim Super Likes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/discovery'),
                  child: const Text('Continue to app', style: TextStyle(color: Colors.white70)),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}
