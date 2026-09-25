// lib/shared/providers/inbox_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/services/backend_service.dart';

import '../models/inbox_item.dart';

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(backendServiceProvider).currentUser;
});

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  return InboxRepository(ref.watch(backendServiceProvider));
});

/// Talks to the PHP API (`GET /matches`, `DELETE /matches/{id}`).
class InboxRepository {
  final BackendService _backend;

  InboxRepository(this._backend);

  Future<List<InboxItem>> fetchInbox() async {
    final matches = await _backend.fetchMatches(limit: 30);
    return [
      for (final m in matches)
        InboxItem(
          matchId: m['id']?.toString() ?? '',
          peerUid: m['user']?['id']?.toString() ?? '',
          matchName: (m['user']?['name'] ?? 'Someone').toString(),
          avatarUrl: m['user']?['photo']?.toString() ?? '',
          isOnline: false,
          isSuperLike: false,
          isMuted: false,
          isPinned: false,
          unreadCount: 0,
          messageCount: m['lastMessage'] == null ? 0 : 1,
          lastMessagePreview:
              m['lastMessage']?['body']?.toString() ?? 'Say hi 👋',
          lastMessageAt: DateTime.tryParse(
                  m['lastMessage']?['at']?.toString() ??
                      m['matchedAt']?.toString() ??
                      '') ??
              DateTime.now(),
          lastMessageFromMe: m['lastMessage']?['fromMe'] == true,
          isTyping: false,
          lastMessageIsVoiceNote: false,
          lastMessageDuration: '',
        ),
    ];
  }

  Future<void> unmatch(String matchId) => _backend.unmatch(matchId);
}

class InboxNotifier extends StateNotifier<AsyncValue<List<InboxItem>>> {
  final InboxRepository _repository;
  Timer? _pollTimer;

  InboxNotifier(this._repository) : super(const AsyncValue.loading()) {
    _start();
  }

  void _start() {
    _loadInbox();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadInbox(silent: true),
    );
  }

  Future<void> _loadInbox({bool silent = false}) async {
    if (!silent) state = const AsyncValue.loading();
    try {
      final items = await _repository.fetchInbox();
      if (!mounted) return;
      state = AsyncValue.data(items);
    } catch (error, stack) {
      // Keep previous data on background refresh failures.
      if (silent && state.hasValue) return;
      if (!mounted) return;
      state = AsyncValue.error(error, stack);
    }
  }

  List<InboxItem> get filtered => state.valueOrNull ?? [];

  int get totalUnread {
    final items = state.valueOrNull ?? [];
    return items.fold(0, (sum, item) => sum + item.unreadCount);
  }

  Future<void> deleteConversation(String matchId) async {
    // Optimistic removal, then best-effort server unmatch.
    final items = state.valueOrNull ?? [];
    state = AsyncValue.data(
      items.where((i) => i.matchId != matchId).toList(),
    );
    try {
      await _repository.unmatch(matchId);
    } catch (_) {
      await _loadInbox(silent: true);
    }
  }

  Future<void> toggleMute(String matchId) async {}
  Future<void> togglePin(String matchId) async {}
  Future<void> toggleReadStatus(String matchId) async {}
  Future<void> acceptRequest(String requestId) async {}
  Future<void> declineRequest(String requestId) async {}
  Future<void> undoDecline(String requestId) async {}

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final inboxProvider =
    StateNotifierProvider<InboxNotifier, AsyncValue<List<InboxItem>>>((ref) {
  return InboxNotifier(ref.watch(inboxRepositoryProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final activeTabProvider = StateProvider<InboxTab>((ref) => InboxTab.all);

final filteredConversationsProvider = Provider<List<InboxItem>>((ref) {
  final inboxState = ref.watch(inboxProvider);
  final query = ref.watch(searchQueryProvider);
  final tab = ref.watch(activeTabProvider);

  var filtered = inboxState.valueOrNull ?? [];
  if (tab == InboxTab.unread) {
    filtered = filtered.where((i) => i.unreadCount > 0).toList();
  }

  if (query.isNotEmpty) {
    final lowerQuery = query.toLowerCase();
    filtered = filtered
        .where((i) =>
            i.matchName.toLowerCase().contains(lowerQuery) ||
            i.lastMessagePreview.toLowerCase().contains(lowerQuery))
        .toList();
  }

  return filtered;
});

final totalUnreadProvider = Provider<int>((ref) {
  final items = ref.watch(inboxProvider).valueOrNull ?? [];
  return items.fold(0, (sum, item) => sum + item.unreadCount);
});

final requestsProvider = StreamProvider<List<ChatRequest>>((ref) {
  return Stream.value([]);
});

final isPremiumProvider = Provider<bool>((ref) => false);

enum InboxTab { all, unread, requests }
