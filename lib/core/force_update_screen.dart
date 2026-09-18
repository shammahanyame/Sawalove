import 'package:flutter/material.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  void _launchAppStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirect to app store (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Update icon
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update,
                    size: 80,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Update Required',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'New version available with important security fixes and features.',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.new_releases, color: Colors.orange),
                            SizedBox(width: 12),
                            Text('What\'s new:', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text('• Improved moderation'),
                        Text('• Bug fixes'),
                        Text('• Better performance'),
                        SizedBox(height: 12),
                        Text('v2.1.0', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.system_update_alt),
                    label: const Text('Update Now', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => _launchAppStore(context),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, color: Colors.white),
                  label: const Text('Later', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  onPressed: () {
                    // Mock dismiss for testing
                    Navigator.of(context).pop();
                  },
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
