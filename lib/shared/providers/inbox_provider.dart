// lib/shared/providers/inbox_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/services/firebase_service.dart';

import '../models/inbox_item.dart';

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(firebaseServiceProvider).currentUser;
});

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  return InboxRepository();
});

class InboxRepository {
  Stream<List<InboxItem>> watchInbox(String uid) {
    return Stream.value([]);
  }

  Future<void> markRead(String uid, String matchId) async {}

  Future<void> deleteConversation(String uid, String matchId) async {}

  Future<void> muteConversation(String uid, String matchId, bool mute) async {}

  Future<void> pinConversation(String uid, String matchId, bool pin) async {}

  Future<void> acceptRequest(String uid, String requestId) async {}

  Future<void> declineRequest(String uid, String requestId) async {}

  Future<void> undoDeclineRequest(String uid, String requestId) async {}
}

class InboxNotifier extends StateNotifier<AsyncValue<List<InboxItem>>> {
  final InboxRepository _repository;
  final String _uid;

  InboxNotifier(this._repository, this._uid) : super(const AsyncValue.loading()) {
    _loadInbox();
  }

  void _loadInbox() {
    _repository.watchInbox(_uid).listen(
          (items) => state = AsyncValue.data(items),
          onError: (error, stack) => state = AsyncValue.error(error, stack),
        );
  }

  List<InboxItem> get filtered => state.valueOrNull ?? [];

  int get totalUnread {
    final items = state.valueOrNull ?? [];
    return items.fold(0, (sum, item) => sum + item.unreadCount);
  }

  Future<void> markReadLocally(String matchId) async {
    await _repository.markRead(_uid, matchId);
  }

  Future<void> deleteConversation(String matchId) async {
    await _repository.deleteConversation(_uid, matchId);
  }

  Future<void> toggleMute(String matchId) async {
    final items = state.valueOrNull ?? [];
    final item = items.firstWhere((i) => i.matchId == matchId);
    await _repository.muteConversation(_uid, matchId, !item.isMuted);
  }

  Future<void> togglePin(String matchId) async {
    final items = state.valueOrNull ?? [];
    final item = items.firstWhere((i) => i.matchId == matchId);
    await _repository.pinConversation(_uid, matchId, !item.isPinned);
  }

  Future<void> toggleReadStatus(String matchId) async {
    final items = [...state.valueOrNull ?? <InboxItem>[]];
    final index = items.indexWhere((item) => item.matchId == matchId);
    if (index == -1) return;

    final item = items[index];
    items[index] = InboxItem(
      matchId: item.matchId,
      matchName: item.matchName,
      avatarUrl: item.avatarUrl,
      isOnline: item.isOnline,
      isSuperLike: item.isSuperLike,
      isMuted: item.isMuted,
      isPinned: item.isPinned,
      unreadCount: item.unreadCount > 0 ? 0 : 1,
      messageCount: item.messageCount,
      lastMessagePreview: item.lastMessagePreview,
      lastMessageAt: item.lastMessageAt,
      lastMessageFromMe: item.lastMessageFromMe,
      isTyping: item.isTyping,
      lastMessageIsVoiceNote: item.lastMessageIsVoiceNote,
      lastMessageDuration: item.lastMessageDuration,
    );
    state = AsyncValue.data(items);
  }

  Future<void> acceptRequest(String requestId) async {
    await _repository.acceptRequest(_uid, requestId);
  }

  Future<void> declineRequest(String requestId) async {
    await _repository.declineRequest(_uid, requestId);
  }

  Future<void> undoDecline(String requestId) async {
    if (_uid.isEmpty) return;
    await _repository.undoDeclineRequest(_uid, requestId);
  }
}

final inboxProvider =
    StateNotifierProvider<InboxNotifier, AsyncValue<List<InboxItem>>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    return _InboxNotifierStub();
  }
  final repository = ref.watch(inboxRepositoryProvider);
  return InboxNotifier(repository, uid);
});

class _InboxNotifierStub extends InboxNotifier {
  _InboxNotifierStub() : super(InboxRepository(), '');
}

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
