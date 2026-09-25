import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'gif_sticker_picker.dart';
import 'models/sticker.dart';
import 'providers/chat_messages_provider.dart';
import '../../core/theme/theme.dart';
import '../../shared/services/backend_service.dart';

/// The match (and peer profile) behind a chat thread. Resolves the peer's
/// user id, which report/block actions need — the server never accepts a
/// match id in their place.
final chatMatchProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>(
  (ref, matchId) => ref.watch(backendServiceProvider).fetchMatch(matchId),
);

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String matchId;
  const ChatDetailScreen({super.key, required this.matchId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _textController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() => _sendText(_textController.text);

  Future<void> _sendText(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await sendChatMessage(ref, widget.matchId, text);
      _textController.clear();
      // Refresh the thread immediately rather than waiting for the poll.
      ref.invalidate(chatMessagesProvider(widget.matchId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.matchId));
    final matchAsync = ref.watch(chatMatchProvider(widget.matchId));
    final peer = matchAsync.valueOrNull?['user'];
    final peerUid = peer is Map ? peer['id']?.toString() ?? '' : '';
    final peerName = peer is Map ? peer['name']?.toString() : null;

    return Scaffold(
      appBar: AppBar(
        // Peer name comes from GET /matches/{id}; 'Chat' avoids inventing
        // a fake person while it loads.
        title: Text(peerName ?? 'Chat'),
        leading: BackButton(
          // Entered via `go` (match success, calls) there is no stack to
          // pop — fall back to the inbox instead of trapping the user.
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home/chat');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (sheetContext) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.flag_outlined),
                      title: const Text('Report user'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        // Reports target a USER id — a match id 404s.
                        if (peerUid.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Still loading this profile…'),
                            ),
                          );
                          return;
                        }
                        context.push('/safety/report/$peerUid');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.link_off),
                      title: const Text('Unmatch'),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        final unmatched = await context.push<bool>(
                          '/unmatch?matchId=${Uri.encodeComponent(widget.matchId)}',
                        );
                        if (unmatched == true && context.mounted) {
                          // The conversation no longer exists server-side
                          // (from my side) — return to the inbox.
                          context.go('/home/chat');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  // Server message shape: {id, senderId, fromMe, body, createdAt}.
                  final msg = messages[index];
                  final isOutgoing = msg['fromMe'] == true;
                  return Align(
                    alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isOutgoing ? SawaLoveTheme.primary : SawaLoveTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(msg['body']?.toString() ?? ''),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 40, color: SawaLoveTheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    const Text('Could not load messages.'),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () =>
                          ref.invalidate(chatMessagesProvider(widget.matchId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Input Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SawaLoveTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Stickers',
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  color: SawaLoveTheme.primary,
                  onPressed: () async {
                    final picked = await showModalBottomSheet<Object>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const GifStickerPicker(),
                    );
                    // A sticker is an offline emoji — send it as a normal
                    // chat message so the receiver actually sees it.
                    if (picked is Sticker && mounted) {
                      await _sendText(picked.url);
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: SawaLoveTheme.surfaceContainerLow,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


