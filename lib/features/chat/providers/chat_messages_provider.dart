import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatMessagesProvider =
    StreamProvider.family<List<dynamic>, String>((ref, conversationId) {
  return Stream.value([]);
});
