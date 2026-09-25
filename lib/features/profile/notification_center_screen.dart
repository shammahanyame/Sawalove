import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/models/inbox_item.dart';
import '../../../shared/providers/inbox_provider.dart';
import '../matches/likes_matches_screen.dart';

/// Activity feed backed by real API data: incoming likes (`GET /likes`) and
/// matches/conversations (`GET /matches`). The old version showed invented
/// "Sarah K. liked your photo" entries — fabricated social activity, which
/// Play's Deceptive Behaviour policy treats as grounds for removal.
class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  Widget _empty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off,
                size: 64, color: SawaLoveTheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: SawaLoveTheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String photo, String name) {
    return CircleAvatar(
      backgroundColor: SawaLoveTheme.primary.withValues(alpha: 0.2),
      foregroundImage:
          photo.isEmpty ? null : CachedNetworkImageProvider(photo),
      child: photo.isEmpty
          ? Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: SawaLoveTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildLikes() {
    final likesAsync = ref.watch(incomingLikesProvider);
    return likesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Could not load likes.'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(incomingLikesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (likes) {
        if (likes.isEmpty) return _empty('No new likes yet.');
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(incomingLikesProvider),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: likes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final profile = likes[index];
              final uid = profile['id']?.toString() ?? '';
              final name = profile['name']?.toString().trim() ?? '';
              final displayName =
                  name.isEmpty ? 'SawaLove user' : name.split(' ').first;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: _avatar(
                  profile['photo']?.toString() ?? '',
                  displayName,
                ),
                title: Text(displayName),
                subtitle: const Text('Likes you'),
                trailing: const Icon(Icons.chevron_right,
                    color: SawaLoveTheme.onSurfaceVariant),
                onTap: uid.isEmpty ? null : () => context.push('/profile/$uid'),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMatches(List<InboxItem> matches) {
    if (matches.isEmpty) return _empty('No new matches yet.');
    return ListView.separated(
      itemCount: matches.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = matches[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _avatar(item.avatarUrl, item.matchName),
          title: Text(item.matchName),
          subtitle: const Text('New match — say hello!'),
          trailing: Text(
            _timeAgo(item.lastMessageAt),
            style: const TextStyle(
                color: SawaLoveTheme.onSurfaceVariant, fontSize: 12),
          ),
          onTap: () =>
              context.push('/chat/${Uri.encodeComponent(item.matchId)}'),
        );
      },
    );
  }

  Widget _buildMessages(List<InboxItem> conversations) {
    if (conversations.isEmpty) return _empty('No new messages yet.');
    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = conversations[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _avatar(item.avatarUrl, item.matchName),
          title: Text(item.matchName),
          subtitle: Text(
            item.lastMessageFromMe
                ? 'You: ${item.lastMessagePreview}'
                : item.lastMessagePreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            _timeAgo(item.lastMessageAt),
            style: const TextStyle(
                color: SawaLoveTheme.onSurfaceVariant, fontSize: 12),
          ),
          onTap: () =>
              context.push('/chat/${Uri.encodeComponent(item.matchId)}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsync = ref.watch(inboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: SawaLoveTheme.primary,
          unselectedLabelColor: SawaLoveTheme.onSurfaceVariant,
          indicatorColor: SawaLoveTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.thumb_up), text: 'Likes'),
            Tab(icon: Icon(Icons.favorite), text: 'Matches'),
            Tab(icon: Icon(Icons.message), text: 'Messages'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLikes(),
            // Matches & messages share the inbox; a match with no messages
            // is a new match, anything else is a conversation.
            inboxAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Could not load activity.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(inboxProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) => _buildMatches(
                items.where((i) => i.messageCount == 0).toList(),
              ),
            ),
            inboxAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Could not load activity.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(inboxProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) => _buildMessages(
                items.where((i) => i.messageCount > 0).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
