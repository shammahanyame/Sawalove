import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/services/backend_service.dart';

/// Recent calls for the signed-in user, read from the `calls` table (RLS
/// limits the rows to calls the user took part in).
final callHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(backendServiceProvider).fetchCallHistory();
});

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(callHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calls')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _HistoryError(
          onRetry: () => ref.invalidate(callHistoryProvider),
        ),
        data: (calls) {
          if (calls.isEmpty) return const _EmptyHistory();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(callHistoryProvider.future),
            child: ListView.separated(
              itemCount: calls.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _CallTile(call: calls[index]),
            ),
          );
        },
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  const _CallTile({required this.call});

  final Map<String, dynamic> call;

  @override
  Widget build(BuildContext context) {
    final name = call['peerName']?.toString() ?? 'SawaLove member';
    final photo = call['peerPhoto']?.toString() ?? '';
    final matchId = call['matchId']?.toString() ?? '';
    final outgoing = call['outgoing'] == true;
    final missed = call['missed'] == true;
    final label = call['label']?.toString() ?? '';
    final duration = call['durationLabel']?.toString() ?? '0:00';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: SawaLoveTheme.surfaceContainerLow,
        backgroundImage:
            photo.isEmpty ? null : CachedNetworkImageProvider(photo),
        child: photo.isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(name),
      subtitle: Row(
        children: [
          Icon(
            missed
                ? Icons.call_missed
                : (outgoing ? Icons.call_made : Icons.call_received),
            size: 16,
            color: missed
                ? SawaLoveTheme.errorColor
                : SawaLoveTheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Flexible(child: Text('$label · $duration')),
        ],
      ),
      trailing: matchId.isEmpty
          ? null
          : IconButton(
              tooltip: 'Call back',
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () => context.push(
                Uri(
                  path: '/chat/video-call',
                  queryParameters: {'matchId': matchId, 'name': name},
                ).toString(),
              ),
            ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call_outlined,
              size: 48, color: SawaLoveTheme.onSurfaceVariant),
          SizedBox(height: 12),
          Text('No calls yet'),
          SizedBox(height: 4),
          Text(
            'Video calls you make or take show up here.',
            style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 40, color: SawaLoveTheme.onSurfaceVariant),
          const SizedBox(height: 12),
          const Text('Could not load your calls.'),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
