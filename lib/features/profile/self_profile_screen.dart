import 'package:flutter/material.dart';

class SelfProfileScreen extends StatelessWidget {
  const SelfProfileScreen({super.key});

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

