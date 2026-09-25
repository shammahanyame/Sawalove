class InboxItem {
  final String matchId;

  /// The other participant's user id — required for report/block actions
  /// (the server expects a user id, never a match id).
  final String peerUid;
  final String matchName;
  final String avatarUrl;
  final bool isOnline;
  final bool isSuperLike;
  final bool isMuted;
  final bool isPinned;
  final int unreadCount;
  final int messageCount;
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final bool lastMessageFromMe;
  final bool isTyping;
  final bool lastMessageIsVoiceNote;
  final String? lastMessageDuration;

  InboxItem({
    required this.matchId,
    this.peerUid = '',
    required this.matchName,
    required this.avatarUrl,
    this.isOnline = false,
    this.isSuperLike = false,
    this.isMuted = false,
    this.isPinned = false,
    this.unreadCount = 0,
    this.messageCount = 0,
    this.lastMessagePreview = '',
    required this.lastMessageAt,
    this.lastMessageFromMe = false,
    this.isTyping = false,
    this.lastMessageIsVoiceNote = false,
    this.lastMessageDuration,
  });

  factory InboxItem.fromJson(Map<String, dynamic> data) {
    return InboxItem(
      matchId: data['matchId'] as String? ?? data['match_id'] as String? ?? '',
      peerUid: data['peerUid'] as String? ?? data['peer_uid'] as String? ?? '',
      matchName: data['matchName'] as String? ?? data['match_name'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? data['avatar_url'] as String? ?? '',
      isOnline: data['isOnline'] as bool? ?? data['is_online'] as bool? ?? false,
      isSuperLike:
          data['isSuperLike'] as bool? ?? data['is_super_like'] as bool? ?? false,
      isMuted: data['isMuted'] as bool? ?? data['is_muted'] as bool? ?? false,
      isPinned: data['isPinned'] as bool? ?? data['is_pinned'] as bool? ?? false,
      unreadCount:
          data['unreadCount'] as int? ?? data['unread_count'] as int? ?? 0,
      messageCount:
          data['messageCount'] as int? ?? data['message_count'] as int? ?? 0,
      lastMessagePreview: data['lastMessagePreview'] as String? ??
          data['last_message_preview'] as String? ??
          '',
      lastMessageAt: _dateFrom(data['lastMessageAt'] ?? data['last_message_at']),
      lastMessageFromMe: data['lastMessageFromMe'] as bool? ??
          data['last_message_from_me'] as bool? ??
          false,
      isTyping: data['isTyping'] as bool? ?? data['is_typing'] as bool? ?? false,
      lastMessageIsVoiceNote: data['lastMessageIsVoiceNote'] as bool? ??
          data['last_message_is_voice_note'] as bool? ??
          false,
      lastMessageDuration:
          data['lastMessageDuration'] as String? ?? data['last_message_duration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'match_id': matchId,
      'peer_uid': peerUid,
      'match_name': matchName,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'is_super_like': isSuperLike,
      'is_muted': isMuted,
      'is_pinned': isPinned,
      'unread_count': unreadCount,
      'message_count': messageCount,
      'last_message_preview': lastMessagePreview,
      'last_message_at': lastMessageAt.toIso8601String(),
      'last_message_from_me': lastMessageFromMe,
      'is_typing': isTyping,
      'last_message_is_voice_note': lastMessageIsVoiceNote,
      'last_message_duration': lastMessageDuration,
    };
  }
}

class ChatRequest {
  final String id;
  final String senderId;
  final String recipientId;
  final String senderName;
  final String avatarUrl;
  final String message;
  final String status;
  final DateTime sentAt;
  final DateTime expiresAt;
  final DateTime? declinedAt;
  final DateTime? undoDeadline;
  final String? matchId;

  const ChatRequest({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.senderName,
    required this.avatarUrl,
    required this.message,
    required this.status,
    required this.sentAt,
    required this.expiresAt,
    this.declinedAt,
    this.undoDeadline,
    this.matchId,
  });

  String get preview => message.length > 60 ? '${message.substring(0, 60)}...' : message;

  bool get isPending => status == 'pending';
  bool get isExpired => status == 'expired';
  bool get canUndo =>
      status == 'declined' &&
      undoDeadline != null &&
      undoDeadline!.isAfter(DateTime.now());

  factory ChatRequest.fromJson(Map<String, dynamic> data) {
    return ChatRequest(
      id: data['id'] as String? ?? '',
      senderId: data['senderId'] as String? ?? data['sender_id'] as String? ?? '',
      recipientId:
          data['recipientId'] as String? ?? data['recipient_id'] as String? ?? '',
      senderName:
          data['senderName'] as String? ?? data['sender_name'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? data['avatar_url'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      sentAt: _dateFrom(data['sentAt'] ?? data['sent_at']),
      expiresAt: _dateFrom(data['expiresAt'] ?? data['expires_at']),
      declinedAt: _nullableDateFrom(data['declinedAt'] ?? data['declined_at']),
      undoDeadline:
          _nullableDateFrom(data['undoDeadline'] ?? data['undo_deadline']),
      matchId: data['matchId'] as String? ?? data['match_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'sender_name': senderName,
      'avatar_url': avatarUrl,
      'message': message,
      'status': status,
      'sent_at': sentAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      if (declinedAt != null) 'declined_at': declinedAt!.toIso8601String(),
      if (undoDeadline != null) 'undo_deadline': undoDeadline!.toIso8601String(),
      if (matchId != null) 'match_id': matchId,
    };
  }
}

DateTime _dateFrom(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

DateTime? _nullableDateFrom(Object? value) {
  if (value == null) return null;
  return _dateFrom(value);
}
