import 'dart:math' as math;

class VoiceMessage {
  final String id;
  final String type;
  final String senderId;
  final String? receiverId;
  final String audioUrl;
  final int durationMs;
  final List<double> amplitudeData;
  final DateTime sentAt;
  final bool flagged;
  final String? flagReason;
  final String? transcription;
  final int? messageCountAtSend;

  VoiceMessage({
    required this.id,
    this.type = 'voice_note',
    required this.senderId,
    this.receiverId,
    required this.audioUrl,
    required this.durationMs,
    required this.amplitudeData,
    required this.sentAt,
    this.flagged = false,
    this.flagReason,
    this.transcription,
    this.messageCountAtSend,
  });

  factory VoiceMessage.fromJson(Map<String, dynamic> data) {
    return VoiceMessage(
      id: data['id'] as String? ?? '',
      senderId: data['senderId'] as String? ?? data['sender_id'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? data['receiver_id'] as String?,
      audioUrl: data['audioUrl'] as String? ?? data['audio_url'] as String? ?? '',
      durationMs: data['durationMs'] as int? ?? data['duration_ms'] as int? ?? 0,
      amplitudeData: List<double>.from(
        (data['amplitudeData'] ?? data['amplitude_data'] ?? <double>[])
            .map((x) => (x as num).toDouble()),
      ),
      sentAt: _dateFrom(data['sentAt'] ?? data['sent_at']),
      flagged: data['flagged'] as bool? ?? false,
      flagReason: data['flagReason'] as String? ?? data['flag_reason'] as String?,
      transcription: data['transcription'] as String?,
      messageCountAtSend:
          data['messageCountAtSend'] as int? ?? data['message_count_at_send'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'audio_url': audioUrl,
      'duration_ms': durationMs,
      'amplitude_data': amplitudeData,
      'sent_at': sentAt.toIso8601String(),
      'flagged': flagged,
      'flag_reason': flagReason,
      'transcription': transcription,
      'message_count_at_send': messageCountAtSend,
    };
  }

  List<double> get fallbackAmplitudeData {
    return List.generate(50, (i) => 0.3 + 0.4 * math.sin(2 * math.pi * i / 50));
  }

  String get durationDisplay {
    final mins = durationMs ~/ 60000;
    final secs = (durationMs % 60000) ~/ 1000;
    return mins > 0 ? '$mins:${secs.toString().padLeft(2, '0')}' : '$secs';
  }
}

DateTime _dateFrom(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
