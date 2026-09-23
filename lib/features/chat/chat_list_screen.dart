// lib/features/chat/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/providers/inbox_provider.dart';
import 'package:sawalove/shared/models/inbox_item.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets/chat_request_card.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsync = ref.watch(inboxProvider);
    final totalUnread = ref.watch(totalUnreadProvider);
    final currentTab = ref.watch(activeTabProvider);

    _tabController.index = currentTab.index;

    return Scaffold(
      backgroundColor: SawaLoveTheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (totalUnread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  totalUnread > 99 ? '99+' : '$totalUnread new',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36 + 1), // +1 for border
          child: Column(
            children: [
              Container(
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: SawaLoveTheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search conversations',
                    prefixIcon: Icon(
                      Icons.search,
                      color: SawaLoveTheme.onSurfaceVariant,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              TabBar(
                controller: _tabController,
                labelColor: SawaLoveTheme.primary,
                unselectedLabelColor: SawaLoveTheme.onSurfaceVariant,
                indicatorColor: SawaLoveTheme.primary,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Unread'),
                  Tab(text: 'Requests'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: inboxAsync.when(
        data: (items) {
          final filteredItems = ref.watch(filteredConversationsProvider);
          return TabBarView(
            controller: _tabController,
            children: [
              _buildListView(filteredItems, currentTab == InboxTab.all),
              _buildUnreadView(filteredItems),
              _buildRequestsView(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildListView(List<InboxItem> items, bool showSections) {
    if (items.isEmpty) {
      return _emptyInbox();
    }

    final newMatches = items.where((item) => item.messageCount == 0).toList();
    final conversations = items.where((item) => item.messageCount > 0).toList();

    return ListView.builder(
      itemCount: (showSections && newMatches.isNotEmpty ? 1 : 0) +
                 conversations.length,
      itemBuilder: (context, index) {
        if (showSections && newMatches.isNotEmpty && index == 0) {
          return _newMatchesSection(newMatches);
        }
        final conversationIndex = showSections && newMatches.isNotEmpty 
            ? index - 1 
            : index;
        return _conversationRow(conversations[conversationIndex]);
      },
    );
  }

  Widget _conversationRow(InboxItem item) {
    return Dismissible(
      key: ValueKey(item.matchId),
      direction: DismissDirection.endToStart,
      background: _swipeBackground(item),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete conversation?'),
              content: const Text('This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: SawaLoveTheme.errorColor,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          return result;
        }
        return false;
      },
      onDismissed: (direction) {
        ref.read(inboxProvider.notifier).deleteConversation(item.matchId);
      },
      child: InkWell(
        onTap: () => context.go('/chat/${item.matchId}'),
        onLongPress: () => _showContextMenu(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: item.unreadCount > 0
              ? SawaLoveTheme.surfaceContainerLowest
              : SawaLoveTheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar with overlays
              _avatarWithOverlays(item),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.matchName,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: item.unreadCount > 0 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(item.lastMessageAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SawaLoveTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _previewText(item),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: item.unreadCount > 0 
                            ? SawaLoveTheme.onSurface 
                            : SawaLoveTheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Right badge
              if (item.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SawaLoveTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.unreadCount > 99 ? '99+' : '${item.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (item.messageCount == 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SawaLoveTheme.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'New match - Nouveau match',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarWithOverlays(InboxItem item) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: CachedNetworkImage(
            imageUrl: item.avatarUrl,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: SawaLoveTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item.matchName.isNotEmpty ? item.matchName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: SawaLoveTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: SawaLoveTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: SawaLoveTheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ),
        // Online dot
        if (item.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: SawaLoveTheme.surfaceContainerLowest,
                  width: 2,
                ),
              ),
            ),
          ),
        // Super Like star
        if (item.isSuperLike)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: SawaLoveTheme.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        // Muted speaker
        if (item.isMuted)
          const Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.volume_off_outlined,
              color: SawaLoveTheme.onSurfaceVariant,
              size: 16,
            ),
          ),
        // Pin icon (Premium)
        if (item.isPinned)
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: SawaLoveTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.push_pin,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _swipeBackground(InboxItem item) {
    return Stack(
      children: [
        Container(
          color: SawaLoveTheme.success.withValues(alpha: 0.1),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.volume_off,
            color: SawaLoveTheme.success,
            size: 24,
          ),
        ),
        Container(
          color: SawaLoveTheme.errorColor.withValues(alpha: 0.1),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 72),
          child: const Icon(
            Icons.delete,
            color: SawaLoveTheme.errorColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  void _showContextMenu(InboxItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                item.unreadCount > 0 ? Icons.mark_chat_read : Icons.mark_chat_unread,
                color: SawaLoveTheme.primary,
              ),
              title: Text(item.unreadCount > 0 ? 'Mark as read' : 'Mark as unread'),
              onTap: () {
                ref.read(inboxProvider.notifier).toggleReadStatus(item.matchId);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                item.isMuted ? Icons.volume_up : Icons.volume_off,
                color: item.isMuted ? SawaLoveTheme.success : SawaLoveTheme.onSurfaceVariant,
              ),
              title: Text(item.isMuted ? 'Unmute' : 'Mute'),
              onTap: () {
                ref.read(inboxProvider.notifier).toggleMute(item.matchId);
                Navigator.pop(context);
              },
            ),
            if (ref.read(isPremiumProvider))
              ListTile(
                leading: Icon(
                  item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: SawaLoveTheme.primary,
                ),
                title: Text(item.isPinned ? 'Unpin' : 'Pin'),
                onTap: () {
                  ref.read(inboxProvider.notifier).togglePin(item.matchId);
                  Navigator.pop(context);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.star_purple500, color: SawaLoveTheme.warning),
                title: const Text('Pin conversation'),
                subtitle: const Text('Premium feature'),
                onTap: () {
                  context.go('/premium');
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.block, color: SawaLoveTheme.errorColor),
              title: const Text('Block user'),
              onTap: () {
                context.go('/safety/block/${item.matchId}');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: SawaLoveTheme.warning),
              title: const Text('Report'),
              onTap: () {
                context.go('/safety/report/${item.matchId}');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _previewText(InboxItem item) {
    if (item.isTyping) {
      return 'typing...';
    } else if (item.lastMessageIsVoiceNote) {
      return 'Voice message - ${item.lastMessageDuration}';
    } else if (item.lastMessageFromMe) {
      return 'You: ${item.lastMessagePreview}';
    } else {
      return item.lastMessagePreview;
    }
  }

  Widget _newMatchesSection(List<InboxItem> newMatches) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SawaLoveTheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: SawaLoveTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Recent matches',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: newMatches.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _conversationRow(newMatches[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyInbox() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: SawaLoveTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_outlined,
                size: 48,
                color: SawaLoveTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you match with someone, your conversations will appear here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: SawaLoveTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home/discover'),
              icon: const Icon(Icons.swipe),
              label: const Text('Find matches'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SawaLoveTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadView(List<InboxItem> items) {
    final unreadItems = items.where((item) => item.unreadCount > 0).toList();
    if (unreadItems.isEmpty) {
      return _emptyUnread();
    }
    return ListView.builder(
      itemCount: unreadItems.length,
      itemBuilder: (context, index) => _conversationRow(unreadItems[index]),
    );
  }

  Widget _emptyUnread() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_chat_read_outlined,
              size: 64,
              color: SawaLoveTheme.onSurfaceVariant,
            ),
            SizedBox(height: 24),
            Text(
              'No unread messages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All your conversations are up to date',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: SawaLoveTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsView() {
    final requestsAsync = ref.watch(requestsProvider);
    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _emptyRequests();
        }
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) => ChatRequestCard(request: requests[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _emptyRequests() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mail_outline,
              size: 64,
              color: SawaLoveTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            const Text(
              'No chat requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Premium users can send you messages first',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: SawaLoveTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/premium'),
              icon: const Icon(Icons.star, color: Colors.white),
              label: const Text('Go Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SawaLoveTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${date.month}/${date.day}/${date.year}';
}

