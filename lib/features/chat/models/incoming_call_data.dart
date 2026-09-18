/// Data model for incoming video call parameters
/// Passed from FCM data payload to call screens
class IncomingCallData {
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String matchId;
  final String? token;
  
  // Contextual badges
  final bool superLikedYou;
  final bool isVerified;
  final String? faith;
  
  // Timestamp when call was initiated
  final DateTime? timestamp;

  IncomingCallData({
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.matchId,
    this.token,
    this.superLikedYou = false,
    this.isVerified = false,
    this.faith,
    this.timestamp,
  });

  factory IncomingCallData.fromMap(Map<String, dynamic> map) {
    return IncomingCallData(
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String,
      callerAvatar: map['callerAvatar'] as String?,
      matchId: map['matchId'] as String,
      token: map['token'] as String?,
      superLikedYou: map['superLikedYou'] as bool? ?? false,
      isVerified: map['isVerified'] as bool? ?? false,
      faith: map['faith'] as String?,
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'matchId': matchId,
      'token': token,
      'superLikedYou': superLikedYou,
      'isVerified': isVerified,
      'faith': faith,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  IncomingCallData copyWith({
    String? callerId,
    String? callerName,
    String? callerAvatar,
    String? matchId,
    String? token,
    bool? superLikedYou,
    bool? isVerified,
    String? faith,
    DateTime? timestamp,
  }) {
    return IncomingCallData(
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerAvatar: callerAvatar ?? this.callerAvatar,
      matchId: matchId ?? this.matchId,
      token: token ?? this.token,
      superLikedYou: superLikedYou ?? this.superLikedYou,
      isVerified: isVerified ?? this.isVerified,
      faith: faith ?? this.faith,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Create demo instance for preview/testing
  factory IncomingCallData.demo() {
    return IncomingCallData(
      callerId: 'demo_user_123',
      callerName: 'Amaka N.',
      callerAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      matchId: 'match_abc123',
      token: 'demo_token',
      superLikedYou: true,
      isVerified: true,
      faith: 'Presbyterian',
      timestamp: DateTime.now(),
    );
  }
}

/// Enum representing call ringing result states
enum CallResultState {
  ringing,
  declined,
  missed,
  busyUnavailable,
  accepted,
  reminderScheduled,
}

/// Extension for bilingual text display
extension CallResultStateX on CallResultState {
  String get labelEn {
    switch (this) {
      case CallResultState.ringing:
        return 'Incoming video call';
      case CallResultState.declined:
        return 'Call declined';
      case CallResultState.missed:
        return 'Missed call';
      case CallResultState.busyUnavailable:
        return 'Busy / Unavailable';
      case CallResultState.accepted:
        return 'Call accepted';
      case CallResultState.reminderScheduled:
        return 'Reminder set';
    }
  }

  String get labelFr {
    switch (this) {
      case CallResultState.ringing:
        return 'Appel vidéo entrants';
      case CallResultState.declined:
        return 'Appel refusé';
      case CallResultState.missed:
        return 'Appel manqué';
      case CallResultState.busyUnavailable:
        return 'Occupé / Indisponible';
      case CallResultState.accepted:
        return 'Appel accepté';
      case CallResultState.reminderScheduled:
        return 'Rappel.programmé';
    }
  }
}
