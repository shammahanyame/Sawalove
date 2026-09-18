import 'package:flutter/foundation.dart';

@immutable
class SwipeRecord {
  final String targetUid;
  final String type; // 'like', 'nope', 'superLike'
  final Map<String, dynamic> profile;
  final DateTime timestamp;

  const SwipeRecord({
    required this.targetUid,
    required this.type,
    required this.profile,
    required this.timestamp,
  });
}
