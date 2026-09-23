import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/providers/inbox_provider.dart';
import 'package:sawalove/shared/models/inbox_item.dart';

class ChatRequestCard extends ConsumerWidget {
  final ChatRequest request;
  const ChatRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeclined = request.status == 'declined';
    final canUndo = request.canUndo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Magenta header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE11D48), // Magenta
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: request.avatarUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _timeAgo(request.sentAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Message body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blurred message preview
                GestureDetector(
                  onTap: () => _revealMessage(context),
                  child: Stack(
                    children: [
                      Text(
                        request.preview,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isDeclined)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (!isDeclined)
                        const Center(
                          child: Text(
                            'Tap to read full message',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Compatibility badges
                if (!isDeclined) ...[
                  Wrap(
                    spacing: 8,
                    children: [
                      _compatibilityBadge('Verified'),
                      _compatibilityBadge('Same faith'),
                      _compatibilityBadge('3 shared interests'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You are under no obligation to accept. Declining is completely anonymous.',
                    style: TextStyle(
                      color: SawaLoveTheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: isDeclined && canUndo
                ? Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _undoDecline(context, ref),
                          icon: const Icon(Icons.undo),
                          label: const Text('Undo'),
                          style: TextButton.styleFrom(
                            foregroundColor: SawaLoveTheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Back'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SawaLoveTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _declineRequest(context, ref),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: SawaLoveTheme.errorColor,
                            side: const BorderSide(color: SawaLoveTheme.errorColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptRequest(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _compatibilityBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SawaLoveTheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  void _revealMessage(BuildContext context) {
    // Animate blur fade - implement with AnimatedOpacity + BackdropFilter
    // For now, show full message in SnackBar or full card expansion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(request.message),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _declineRequest(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DeclineConfirmSheet(requestId: request.id),
    );
  }

  void _acceptRequest(BuildContext context, WidgetRef ref) {
    ref.read(inboxProvider.notifier).acceptRequest(request.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request accepted')),
    );
  }

  void _undoDecline(BuildContext context, WidgetRef ref) {
    ref.read(inboxProvider.notifier).undoDecline(request.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Decline undone')),
    );
  }
}

class DeclineConfirmSheet extends ConsumerWidget {
  final String requestId;
  const DeclineConfirmSheet({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Decline request?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'The request will disappear and sender will not be notified. You can undo within 24 hours. Sender cannot send again for 30 days.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(inboxProvider.notifier).declineRequest(requestId);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SawaLoveTheme.errorColor,
                  ),
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
