import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';

class DeclineConfirmScreen extends ConsumerWidget {
  final String requestId;
  const DeclineConfirmScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decline Request')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              size: 64,
              color: SawaLoveTheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Request declined',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'The request has been declined. The sender will not be notified. You can undo this action within 24 hours. The sender cannot send another request for 30 days.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => context.go('/home/chat'),
                    icon: const Icon(Icons.close),
                    label: const Text('Back to inbox'),
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

