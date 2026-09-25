import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/services/backend_service.dart';

/// Conversation messages, backed by the PHP API (`GET/POST /matches/{id}/messages`).
///
/// The stream polls every 5 s while the screen is open;Riverpod disposes the
/// subscription with the screen. Errors propagate to the UI's error branch.
final chatMessagesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, matchId) {
  final backend = ref.watch(backendServiceProvider);

  Future<List<Map<String, dynamic>>> fetch() async {
    try {
      return await backend.fetchMessages(matchId);
    } on BackendAuthException catch (e) {
      // 404 / 410 = unmatched or ended conversation; render as an empty,
      // non-error chat so the UI can show the ended state.
      if (e.statusCode == 404 || e.statusCode == 410) return const [];
      rethrow;
    }
  }

  return Stream<List<Map<String, dynamic>>>.multi((controller) {
    Timer? timer;
    Future<void> emit() async {
      if (controller.isClosed) return;
      try {
        controller.add(await fetch());
      } catch (e, st) {
        controller.addError(e, st);
      }
    }

    emit();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => emit());
    controller.onCancel = () => timer?.cancel();
  });
});

/// Sends a message; returns the stored message or rethrows for the UI.
Future<Map<String, dynamic>> sendChatMessage(
  WidgetRef ref,
  String matchId,
  String body,
) {
  return ref.read(backendServiceProvider).sendMessage(matchId, body);
}
