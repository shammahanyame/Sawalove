import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [SawaLoveTheme.tertiary, Color(0xFF004B5E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Signal bars icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            color: SawaLoveTheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 4, height: 40, color: SawaLoveTheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Container(width: 4, height: 30, color: SawaLoveTheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Container(width: 4, height: 20, color: SawaLoveTheme.outlineVariant),
                              const SizedBox(width: 4),
                              Container(width: 4, height: 10, color: SawaLoveTheme.outlineVariant),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.cloud_off, size: 48, color: SawaLoveTheme.tertiary),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'No Connection',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You\'re offline. Check your connection and try again.',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.phone_android, size: 48, color: SawaLoveTheme.tertiary),
                        SizedBox(height: 16),
                        Text(
                          'Tips while offline:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        SizedBox(height: 12),
                        Text('• View cached messages'),
                        Text('• Edit profile'),
                        Text('• Review matches'),
                        SizedBox(height: 8),
                        Text('New likes/matches when back online', style: TextStyle(color: SawaLoveTheme.success)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SawaLoveTheme.tertiary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: () {
                      // Mock retry
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connection restored!'),
                          backgroundColor: SawaLoveTheme.success,
                        ),
                      );
                      context.pop();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: const Text('App Settings'),
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

