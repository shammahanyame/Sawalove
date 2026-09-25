import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/theme.dart';
import '../../shared/services/backend_service.dart';

/// Accounts the signed-in user has blocked (`GET /blocks`).
final blockedUsersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(backendServiceProvider).fetchBlockedUsers();
});

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedAsync = ref.watch(blockedUsersProvider);

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
                blockedAsync.maybeWhen(
                      data: (users) => 'Blocked (${users.length})',
                      orElse: () => 'Blocked',
                    ),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              const Text(
                'These users cannot message or see your profile.',
                style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: blockedAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) {
                    final notConfigured = error is BackendAuthException &&
                        error.code == 'backend-not-configured';
                    if (notConfigured) return const _EmptyBlockedState();
                    return _BlockedErrorState(
                      onRetry: () => ref.invalidate(blockedUsersProvider),
                    );
                  },
                  data: (users) => users.isEmpty
                      ? const _EmptyBlockedState()
                      : ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _BlockedTile(user: users[index]),
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

class _BlockedTile extends ConsumerWidget {
  const _BlockedTile({required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = user['id']?.toString() ?? '';
    final name = user['name']?.toString();
    final displayName = (name == null || name.trim().isEmpty) ? 'SawaLove user' : name;
    final photo = user['photo']?.toString() ?? '';
    final city = user['city']?.toString() ?? '';
    final age = user['age'];

    final subtitleParts = <String>[
      if (city.isNotEmpty) city,
      if (age != null) '$age',
    ];

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: SawaLoveTheme.primary.withValues(alpha: 0.2),
          foregroundImage: photo.isEmpty ? null : CachedNetworkImageProvider(photo),
          child: photo.isEmpty
              ? Text(
                  displayName.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: SawaLoveTheme.primary,
                  ),
                )
              : null,
        ),
        title: Text(displayName),
        subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' · ')),
        trailing: TextButton(
          onPressed: uid.isEmpty ? null : () => _confirmUnblock(context, ref),
          child: const Text('Unblock'),
        ),
      ),
    );
  }

  Future<void> _confirmUnblock(BuildContext context, WidgetRef ref) async {
    final name = user['name']?.toString().trim() ?? '';
    final displayName = name.isEmpty ? 'this user' : name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unblock?'),
        content: Text(
          'Unblock $displayName? They will be able to see your profile '
          'and message you again if you match.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Unblock',
              style: TextStyle(color: SawaLoveTheme.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(backendServiceProvider).unblockUser(
            user['id']?.toString() ?? '',
          );
      ref.invalidate(blockedUsersProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('$displayName unblocked')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not unblock. Please try again.'),
        ),
      );
    }
  }
}

class _EmptyBlockedState extends StatelessWidget {
  const _EmptyBlockedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block_rounded,
              size: 56, color: SawaLoveTheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            "You haven't blocked anyone",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Blocked users will appear here.',
            style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BlockedErrorState extends StatelessWidget {
  const _BlockedErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Could not load blocked users.'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
