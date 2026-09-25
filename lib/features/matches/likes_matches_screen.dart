import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/core/config/feature_flags.dart';
import 'package:sawalove/shared/models/inbox_item.dart';
import 'package:sawalove/shared/providers/inbox_provider.dart';
import 'package:sawalove/shared/services/backend_service.dart';

/// Users who liked me and I have not swiped yet (`GET /likes`).
final incomingLikesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(backendServiceProvider).fetchIncomingLikes(limit: 40);
});

/// Likes & Matches tab.
///
/// Real data from `GET /likes` and `GET /matches`; in release builds the
/// flag gates it to an honest empty state if the feature is not shipped yet.
class LikesMatchesScreen extends StatelessWidget {
  const LikesMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kShowLikesAndMatches) {
      return const _RealLikesMatchesScreen();
    }
    return const _EmptyLikesMatches();
  }
}

class _RealLikesMatchesScreen extends ConsumerStatefulWidget {
  const _RealLikesMatchesScreen();

  @override
  ConsumerState<_RealLikesMatchesScreen> createState() =>
      _RealLikesMatchesScreenState();
}

class _RealLikesMatchesScreenState
    extends ConsumerState<_RealLikesMatchesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final likesAsync = ref.watch(incomingLikesProvider);
    final matchesAsync = ref.watch(inboxProvider);

    final likeCount = likesAsync.valueOrNull?.length ?? 0;
    final matchCount = matchesAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Likes & Matches'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: SawaLoveTheme.primary,
          unselectedLabelColor: SawaLoveTheme.onSurfaceVariant,
          tabs: [
            Tab(text: likeCount > 0 ? 'Likes ($likeCount)' : 'Likes'),
            Tab(text: matchCount > 0 ? 'Matches ($matchCount)' : 'Matches'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LikesTab(),
          _MatchesTab(),
        ],
      ),
    );
  }
}

class _LikesTab extends ConsumerWidget {
  const _LikesTab();

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(incomingLikesProvider);
    await ref.read(incomingLikesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesAsync = ref.watch(incomingLikesProvider);

    return likesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _RetryState(
        message: 'Could not load likes.',
        onRetry: () => ref.invalidate(incomingLikesProvider),
      ),
      data: (likes) {
        if (likes.isEmpty) {
          return const _EmptyLikesBody();
        }
        return RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: likes.length,
            itemBuilder: (context, index) {
              final profile = likes[index];
              final uid = profile['id']?.toString() ?? '';
              final name = profile['name']?.toString().trim() ?? '';
              final displayName =
                  name.isEmpty ? 'SawaLove user' : name.split(' ').first;
              final age = profile['age'];
              final photo = profile['photo']?.toString() ?? '';

              return GestureDetector(
                onTap: uid.isEmpty ? null : () => context.push('/profile/$uid'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: SawaLoveTheme.surfaceContainer,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (photo.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: photo,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const _AvatarPlaceholder(),
                        )
                      else
                        const _AvatarPlaceholder(),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                          child: Text(
                            age == null
                                ? displayName
                                : '$displayName, $age',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: SawaLoveTheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Likes you',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MatchesTab extends ConsumerWidget {
  const _MatchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(inboxProvider);

    return inboxAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _RetryState(
        message: 'Could not load matches.',
        onRetry: () => ref.invalidate(inboxProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyMatchesBody();
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(inboxProvider),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      SawaLoveTheme.primary.withValues(alpha: 0.2),
                  foregroundImage: item.avatarUrl.isEmpty
                      ? null
                      : CachedNetworkImageProvider(item.avatarUrl),
                  child: item.avatarUrl.isEmpty
                      ? Text(
                          item.matchName.isEmpty
                              ? '?'
                              : item.matchName.characters.first.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: SawaLoveTheme.primary,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  item.matchName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _preview(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: SawaLoveTheme.onSurfaceVariant),
                ),
                trailing: item.unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: const BoxDecoration(
                          color: SawaLoveTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 22, minHeight: 22),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const Icon(Icons.chevron_right,
                        color: SawaLoveTheme.onSurfaceVariant),
                onTap: () =>
                    context.push('/chat/${Uri.encodeComponent(item.matchId)}'),
              );
            },
          ),
        );
      },
    );
  }

  String _preview(InboxItem item) {
    if (item.lastMessagePreview.isEmpty) return 'Say hi 👋';
    if (item.lastMessageFromMe) return 'You: ${item.lastMessagePreview}';
    return item.lastMessagePreview;
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SawaLoveTheme.surfaceContainerLow,
      child: const Icon(
        Icons.person_rounded,
        size: 64,
        color: SawaLoveTheme.onSurfaceVariant,
      ),
    );
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyLikesBody extends StatelessWidget {
  const _EmptyLikesBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 48,
                    color: SawaLoveTheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No likes yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When someone likes your profile, they will appear here.\n'
                    'Keep discovering profiles to get noticed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyMatchesBody extends StatelessWidget {
  const _EmptyMatchesBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: SawaLoveTheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No matches yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When you and someone else like each other, '
                    'your conversations show up here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyLikesMatches extends StatelessWidget {
  const _EmptyLikesMatches();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: _EmptyLikesBody());
  }
}
