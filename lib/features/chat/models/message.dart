import '../../../shared/models/voice_message.dart';

enum MessageType { text, voice, missedCall }

class Message {
  final String id;
  final String senderId;
  final DateTime sentAt;
  final MessageType type;
  final Map<String, dynamic>? content;
  final int? messageCountAtSend;
  final bool flagged;
  final String? matchId;
  final bool isRequestMessage;

  const Message({
    required this.id,
    required this.senderId,
    required this.sentAt,
    required this.type,
    this.content,
    this.messageCountAtSend,
    this.flagged = false,
    this.matchId,
    this.isRequestMessage = false,
  });

  factory Message.fromJson(Map<String, dynamic> data) {
    final typeStr = data['type'] as String? ?? 'text';
    final type = MessageType.values.firstWhere(
      (t) => t.toString().split('.').last == typeStr,
      orElse: () => MessageType.text,
    );

    return Message(
      id: data['id'] as String? ?? '',
      senderId: data['senderId'] as String? ?? data['sender_id'] as String? ?? '',
      sentAt: _dateFrom(data['sentAt'] ?? data['sent_at']),
      type: type,
      content: data,
      messageCountAtSend:
          data['messageCountAtSend'] as int? ?? data['message_count_at_send'] as int?,
      flagged: data['flagged'] as bool? ?? false,
      matchId: data['matchId'] as String? ?? data['match_id'] as String?,
      isRequestMessage: data['isRequestMessage'] as bool? ??
          data['is_request_message'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'sent_at': sentAt.toIso8601String(),
        'type': type.toString().split('.').last,
        if (content != null) ...content!,
        if (messageCountAtSend != null)
          'message_count_at_send': messageCountAtSend,
        'flagged': flagged,
        if (matchId != null) 'match_id': matchId,
        'is_request_message': isRequestMessage,
      };

  bool get isVoice => type == MessageType.voice;
  bool get isText => type == MessageType.text;

  VoiceMessage? get voiceContent {
    if (!isVoice) return null;
    return VoiceMessage.fromJson(content ?? {});
  }
}

DateTime _dateFrom(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
