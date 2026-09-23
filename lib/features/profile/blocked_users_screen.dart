import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock blocked users
    final blockedUsers = [
      {'name': 'Pierre M.', 'reason': 'Inappropriate messages', 'date': '3 days ago'},
      {'name': 'Sarah K.', 'reason': 'Spam', 'date': '1 week ago'},
      {'name': 'David B.', 'reason': 'Safety concern', 'date': '2 weeks ago'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
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
                'Blocked (${blockedUsers.length})',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              const Text(
                'These users cannot message or see your profile.',
                style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: blockedUsers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = blockedUsers[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: SawaLoveTheme.primary.withValues(alpha: 0.2),
                          child: Text(user['name']![0], style: const TextStyle(fontWeight: FontWeight.bold, color: SawaLoveTheme.primary)),
                        ),
                        title: Text(user['name']!),
                        subtitle: Text('${user['reason']} • ${user['date']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.block, color: SawaLoveTheme.errorColor),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Unblock?'),
                                content: Text('Unblock ${user['name']}? They will be able to message you again.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${user['name']} unblocked')),
                                      );
                                    },
                                    child: const Text('Unblock', style: TextStyle(color: SawaLoveTheme.errorColor)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

