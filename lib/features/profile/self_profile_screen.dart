import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/theme.dart';
import '../../core/config/feature_flags.dart';
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
  String? _declaredDob;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final backend = ref.read(backendServiceProvider);
    if (!backend.isConfigured || !backend.isSignedIn) return;
    try {
      final profile = await backend.getUserProfile(backend.currentUserId!);
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _role = profile?['role']?.toString();
        _declaredDob = prefs.getString('sawalove.declared_dob_iso');
      });
    } catch (_) {
      // Role chip is a convenience; ignore fetch failures.
    }
  }

  bool get _isModerator => _role == 'moderator' || _role == 'admin';

  String get _displayName {
    final name = _profile?['name']?.toString().trim() ?? '';
    if (name.isEmpty) return 'Your profile';
    final age = _profile?['age'];
    return age is int ? '$name, $age' : name;
  }

  /// Honest completeness from the fields the API actually returns.
  int get _completeness {
    final p = _profile;
    if (p == null) return 0;
    int points = 0;
    if ((p['photo'] ?? '').toString().isNotEmpty) points += 25;
    if ((p['name'] ?? '').toString().trim().isNotEmpty) points += 15;
    if ((p['bio'] ?? '').toString().trim().length > 30) points += 20;
    if (p['age'] != null) points += 15;
    if ((p['city'] ?? '').toString().trim().isNotEmpty) points += 15;
    if ((p['intent'] ?? '').toString().trim().isNotEmpty) points += 10;
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header (real data from GET /users/{id})
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: SawaLoveTheme.primary.withValues(alpha: 0.2),
                foregroundImage: (_profile?['photo'] ?? '').toString().isNotEmpty
                    ? CachedNetworkImageProvider(_profile!['photo'].toString())
                    : null,
                child: (_profile?['photo'] ?? '').toString().isEmpty
                    ? const Icon(Icons.person_rounded,
                        size: 40, color: SawaLoveTheme.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_displayName,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Profile completeness: $_completeness%'),
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
              onPressed: () => context.push('/profile/edit'),
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
            onTap: () => context.push('/profile/notification-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Safety Center'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/safety'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Account — pause, delete, export'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/account'),
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
          // Legal section (real in-app documents)
          const Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/terms'),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/privacy-policy'),
          ),
          if (_declaredDob != null)
            ListTile(
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Declared date of birth'),
              subtitle: Text(_declaredDob!.split('T').first),
            ),
          if (kShowPremium) ...[
            const SizedBox(height: 24),
            // Premium Upsell (only compiled in when SHOW_PREMIUM=true)
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
                    onPressed: () => context.push('/premium'),
                    child: const Text('Upgrade Now', style: TextStyle(color: Colors.purple)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
