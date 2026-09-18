class Reaction {
  final String uid;
  final String emoji;
  final DateTime reactedAt;

  const Reaction({
    required this.uid,
    required this.emoji,
    required this.reactedAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> data) {
    return Reaction(
      uid: data['uid'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '❤️',
      reactedAt: _dateFrom(data['reactedAt'] ?? data['reacted_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'emoji': emoji,
        'reacted_at': reactedAt.toIso8601String(),
      };
}

DateTime _dateFrom(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
