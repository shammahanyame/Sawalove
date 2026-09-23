import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/services/backend_service.dart';

/// Profile settings hub. Shows the moderator queue entry only when the
/// signed-in account's private payload reports a moderator+ role; the server
/// remains the enforcement point either way.
class SelfProfileScreen extends ConsumerStatefulWidget {
  const SelfProfileScreen({super.key});

  @override
  ConsumerState<SelfProfileScreen> createState() => _SelfProfileScreenState();
}

class _SelfProfileScreenState extends ConsumerState<SelfProfileScreen> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final backend = ref.read(backendServiceProvider);
    if (!backend.isConfigured || !backend.isSignedIn) return;
    try {
      final profile = await backend.getUserProfile(backend.currentUserId!);
      if (!mounted) return;
      setState(() => _role = profile?['role']?.toString());
    } catch (_) {
      // Role chip is a convenience; ignore fetch failures.
    }
  }

  bool get _isModerator => _role == 'moderator' || _role == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header
          const Row(
            children: [
              CircleAvatar(radius: 40),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Name, 24', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Profile completeness: 80%'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Edit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(height: 32),
          // Settings Sections
          const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Text('English'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          if (_isModerator)
            ListTile(
              leading: const Icon(Icons.gavel, color: SawaLoveTheme.primary),
              title: const Text('Moderation queue'),
              subtitle: const Text('Review reported accounts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/moderation'),
            ),
          const SizedBox(height: 24),
          // Premium Upsell
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.pink.shade400],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Go Premium',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Unlimited likes, see who liked you',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, '/premium'),
                  child: const Text('Upgrade Now', style: TextStyle(color: Colors.purple)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

