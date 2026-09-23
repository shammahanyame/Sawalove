import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'gif_sticker_picker.dart';
import 'providers/chat_messages_provider.dart';
import 'widgets/voice_note_bubble.dart';
import 'widgets/recording_overlay.dart';
import 'widgets/safety_flagged_card.dart';
import '../../shared/models/voice_message.dart';
import '../../core/theme/theme.dart';

class ChatDetailScreen extends ConsumerWidget {
  final String matchId;
  const ChatDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatMessagesProvider(matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amaka'),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (sheetContext) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('View profile'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.flag_outlined),
                      title: const Text('Report user'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.push('/safety/report/$matchId');
                      },
                    ),
                    const ListTile(
                      leading: Icon(Icons.block),
                      title: Text('Unmatch'),
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
                  final msg = messages[index];
                  if (msg is VoiceMessage) {
                    // Stub first5 check - assume from msg.messageCountAtSend <5
                    if (msg.flagged && msg.messageCountAtSend != null && msg.messageCountAtSend! < 5) {
                      return SafetyFlaggedCard(message: msg);
                    }
                    final isOutgoing = msg.senderId == 'current_user_uid'; // TODO: FirebaseAuth.currentUser!.uid
                    return VoiceNoteBubble(
                      message: msg,
                      isOutgoing: isOutgoing,
                      key: ValueKey(msg.id),
                    );
                  }
                  // Text message stub
                  final textMsg = msg as Map<String, dynamic>;
                  final isOutgoing = textMsg['senderId'] == 'current_user_uid';
                  return Align(
                    alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isOutgoing ? SawaLoveTheme.primary : SawaLoveTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(textMsg['text'] ?? ''),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
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
                  tooltip: 'GIFs and stickers',
                  icon: const Icon(Icons.gif_box_outlined),
                  color: SawaLoveTheme.primary,
                  onPressed: () async {
                    await showModalBottomSheet<Object>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const GifStickerPicker(),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: SawaLoveTheme.surfaceContainerLow,
                    ),
                    onSubmitted: (text) {
                      // Send text stub
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => RecordingOverlay(conversationId: matchId),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.mic, color: SawaLoveTheme.primary),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Send text
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
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


