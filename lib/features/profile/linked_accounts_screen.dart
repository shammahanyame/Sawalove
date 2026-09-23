import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class LinkedAccountsScreen extends StatelessWidget {
  const LinkedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Linked Accounts'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connect with:',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              // Phone (primary)
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.successContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.phone_android, color: SawaLoveTheme.success),
                  ),
                  title: const Text('Phone Number'),
                  subtitle: const Text('+237 677 123 456'),
                  trailing: const Icon(Icons.verified, color: SawaLoveTheme.success),
                ),
              ),
              const SizedBox(height: 16),
              // Google
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [SawaLoveTheme.tertiary, Color(0xFF004B5E)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                ),
                title: const Text('Google'),
                subtitle: const Text('Connect with Google'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Google sign in
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google connected')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SawaLoveTheme.tertiary,
                  ),
                  child: const Text('Connect', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              // Facebook
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF004B5E), Color(0xFF003242)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.facebook, color: Colors.white, size: 24),
                ),
                title: const Text('Facebook'),
                subtitle: const Text('Sync friends & photos'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Facebook login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Facebook connected')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SawaLoveTheme.tertiary,
                  ),
                  child: const Text('Connect', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              // Benefits
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Why connect?', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      _benefit(Icons.account_circle, 'Faster verification'),
                      _benefit(Icons.photo_library, 'Import photos'),
                      _benefit(Icons.group, 'Find friends'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '⚠️ You can disconnect anytime. Phone number always required.',
                style: TextStyle(color: SawaLoveTheme.warning, fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SawaLoveTheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

