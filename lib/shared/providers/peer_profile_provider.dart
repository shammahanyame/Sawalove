import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/services/firebase_service.dart';

final peerProfileProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  final backend = ref.read(firebaseServiceProvider);
  return backend.getUserProfile(uid);
});
