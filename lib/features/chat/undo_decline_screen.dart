import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/providers/inbox_provider.dart';

class UndoDeclineScreen extends ConsumerWidget {
  final String requestId;
  const UndoDeclineScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Undo Decline')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.undo,
              size: 64,
              color: SawaLoveTheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Undo decline?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'The chat request will be restored to pending status.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => context.go('/home/chat'),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(inboxProvider.notifier).undoDecline(requestId);
                      context.go('/home/chat');
                    },
                    icon: const Icon(Icons.undo),
                    label: const Text('Undo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SawaLoveTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

