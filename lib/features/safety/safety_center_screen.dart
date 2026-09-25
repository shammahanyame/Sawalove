import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/feature_flags.dart';

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Center')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Blocked users'),
              subtitle: const Text('People you have blocked'),
              onTap: () => context.push('/profile/blocked'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Moderation appeal'),
              subtitle: const Text('Appeal a decision on your account'),
              onTap: () => context.push('/safety/moderation-appeal'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('ID verification'),
              onTap: () => context.push('/safety/id-verification'),
            ),
          ),
          if (kShowSos)
            Card(
              child: ListTile(
                leading: const Icon(Icons.emergency_outlined),
                title: const Text('Emergency SOS'),
                subtitle: const Text('Share your location with a trusted contact'),
                onTap: () => context.push('/safety/sos'),
              ),
            ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('Safety tips'),
              subtitle: Text(
                'Meet in public places, keep chats in-app, and never send '
                'money to someone you have not met. Report anything that '
                'feels wrong — reports are always free and confidential.',
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.description_outlined),
              title: Text('Community rules'),
              subtitle: Text('No harassment, no fake profiles, no scams. 18+ only.'),
              onTap: null,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete account'),
              onTap: () => context.push('/profile/account'),
            ),
          ),
        ],
      ),
    );
  }
}
