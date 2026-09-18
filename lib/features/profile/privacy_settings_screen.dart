import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _locationPause = false;
  bool _activeStatus = true;
  bool _showVillage = true;
  final bool _incognitoMode = false;
  bool _readReceipts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              // Location
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_off, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Location Privacy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Pause location'),
                        subtitle: const Text('Hide from "near me" searches'),
                        value: _locationPause,
                        onChanged: (v) => setState(() => _locationPause = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Active status
              SwitchListTile(
                secondary: const Icon(Icons.circle_notifications, color: Colors.green),
                title: const Text('Show Active Status'),
                subtitle: const Text('Green dot when online (15 min)'),
                value: _activeStatus,
                onChanged: (v) => setState(() => _activeStatus = v),
              ),
              const SizedBox(height: 24),
              // Profile visibility
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Profile Visibility', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Show Village of Origin'),
                        subtitle: const Text('Village visible on profile'),
                        value: _showVillage,
                        onChanged: (v) => setState(() => _showVillage = v),
                      ),
                      if (!_activeStatus || _locationPause || !_showVillage)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: SawaLoveTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.shield, color: SawaLoveTheme.primary),
                                SizedBox(height: 8),
                                Text('Enhanced Privacy', style: TextStyle(fontWeight: FontWeight.w600, color: SawaLoveTheme.primary)),
                                Text('Your profile is more private'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Incognito (Premium)
              ListTile(
                leading: Stack(
                  children: [
                    const Icon(Icons.visibility_off, color: Colors.grey),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                title: const Text('Incognito Mode'),
                subtitle: const Text('Premium: Only show to liked users'),
                trailing: _incognitoMode 
                  ? const Icon(Icons.lock, color: Colors.amber, size: 20)
                  : ElevatedButton(
                      onPressed: () {}, // Go premium
                      child: const Text('Premium'),
                    ),
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Chat privacy
              SwitchListTile(
                title: const Text('Read Receipts'),
                subtitle: const Text('Show when messages read'),
                value: _readReceipts,
                onChanged: (v) => setState(() => _readReceipts = v),
              ),
              const SizedBox(height: 24),
              // Moderation appeals
              ListTile(
                leading: const Icon(Icons.gavel, color: Colors.orange),
                title: const Text('Moderation Appeals'),
                subtitle: const Text('Appeal bans or content flags'),
                onTap: () => context.go('/safety/moderation-appeal'),
              ),
              const SizedBox(height: 16),
              // Help & FAQ
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.green),
                title: const Text('Help & FAQ'),
                subtitle: const Text('Searchable help articles'),
                onTap: () => context.go('/profile/help-faq'),
              ),
              // Contact Support
              ListTile(
                leading: const Icon(Icons.support_agent, color: Colors.blue),
                title: const Text('Contact Support'),
                subtitle: const Text('Tickets & chat'),
                onTap: () => context.go('/profile/contact-support'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.purple),
                title: const Text('Notification Center'),
                subtitle: const Text('Likes, matches, messages'),
                onTap: () => context.go('/profile/notification-center'),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Refer Friends'),
                subtitle: const Text('Earn Premium days'),
                onTap: () => context.go('/profile/refer-friends'),
              ),
              const SizedBox(height: 16),
              // Data sharing
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.privacy_tip, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('We never sell your data. Location is city-level only.', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
TextButton(
                      onPressed: () => context.go('/profile/privacy-policy'),
                      child: const Text('Read'),
                    )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

