import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:go_router/go_router.dart';


class ReferFriendsScreen extends StatelessWidget {
  const ReferFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer Friends'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.share,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Invite Friends & Earn Premium!',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Get 3 days Premium for every friend who signs up!',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: SawaLoveTheme.warning),
                        SizedBox(width: 12),
                        Text('Your referrals', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: CircleAvatar(child: Text('J')),
                      title: Text('Jean M.'),
                      subtitle: Text('Signed up - 3 days earned'),
                      trailing: Icon(Icons.check_circle, color: SawaLoveTheme.success),
                    ),
                    ListTile(
                      leading: CircleAvatar(child: Text('P')),
                      title: Text('Pierre K.'),
                      subtitle: Text('Invited'),
                      trailing: Chip(label: Text('Pending')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share Invite Link'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied! Share with friends')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
