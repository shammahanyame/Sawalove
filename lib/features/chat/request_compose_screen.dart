import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/providers/quota_provider.dart';
import 'package:sawalove/shared/providers/peer_profile_provider.dart';
import 'package:sawalove/l10n/app_localizations.dart';

class RequestComposeScreen extends ConsumerStatefulWidget {
  final String recipientUid;
  const RequestComposeScreen({super.key, required this.recipientUid});

  @override
  ConsumerState<RequestComposeScreen> createState() => _RequestComposeScreenState();
}

class _RequestComposeScreenState extends ConsumerState<RequestComposeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || message.length > 200) return;

    setState(() => _isSending = true);

    try {
      ref.read(quotaProvider.notifier).decrementRequest();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).requestSent)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send request. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quota = ref.watch(quotaProvider);
    final requestsRemaining = quota.requestsRemaining;

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatRequest),
        actions: [
          if (requestsRemaining > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: !_isSending && requestsRemaining > 0 ? _sendRequest : null,
                child: _isSending 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.send),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: requestsRemaining > 0
                    ? SawaLoveTheme.primaryContainer.withValues(alpha: 0.8)
                    : SawaLoveTheme.errorColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                requestsRemaining > 0 ? '$requestsRemaining today' : l10n.upgradeToSend,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: requestsRemaining > 0 ? Colors.white : SawaLoveTheme.errorColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
// Recipient Profile Header
          Consumer(
            builder: (context, ref, child) {
              final recipientProfileAsync = ref.watch(peerProfileProvider(widget.recipientUid));
              return recipientProfileAsync.when(
                data: (profile) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: SawaLoveTheme.primaryContainer,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: profile?['photoUrl'] != null 
                          ? NetworkImage(profile!['photoUrl'])
                          : null,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${profile?['name'] ?? 'User'}, ${profile?['age'] ?? '?'}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '${profile?['city'] ?? ''} - ${profile?['intent'] ?? ''}',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                loading: () => Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    color: SawaLoveTheme.primaryContainer,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    color: SawaLoveTheme.errorContainer,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: const Center(child: Icon(Icons.error, color: Colors.white)),
                ),
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(text: l10n.personalisedMessagesTip),
                          const TextSpan(
                            text: '4x',
                            style: TextStyle(fontWeight: FontWeight.bold, color: SawaLoveTheme.primary),
                          ),
                          const TextSpan(text: ' more replies than generic greetings.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quota Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: requestsRemaining > 0 ? SawaLoveTheme.primaryContainer : SawaLoveTheme.errorColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          requestsRemaining > 0 ? Icons.chat : Icons.lock,
                          size: 16,
                          color: requestsRemaining > 0 ? SawaLoveTheme.primary : SawaLoveTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          requestsRemaining > 0 
                            ? '$requestsRemaining ${l10n.requestsRemaining}'
                            : l10n.upgradeToSend,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: requestsRemaining > 0 ? SawaLoveTheme.primary : SawaLoveTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Message Input
                  TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    maxLength: 200,
                    maxLines: 4,
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => Text(
                      '$currentLength / ${maxLength ?? 200}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: currentLength > 180 ? SawaLoveTheme.errorColor : null,
                      ),
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.writePersonalisedMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Preview
                  Text(
                    l10n.preview,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SawaLoveTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SawaLoveTheme.outline),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE11D48), // Magenta
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      l10n.chatRequest,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'Now',
                                    style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _messageController.text.isEmpty ? l10n.messagePreview : _messageController.text,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

