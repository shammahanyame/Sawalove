import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/services/firebase_service.dart';

final discoveryProfilesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final backend = ref.watch(firebaseServiceProvider);
  return backend.watchVisibleUsers(limit: 20);
});

final currentSwipeIndexProvider = StateProvider<int>((ref) => 0);

/// Profiles restored by a rewind. The server excludes already-swiped users
/// from `GET /users`, so a rewound profile only comes back from the local
/// snapshot stored in swipe history.
final rewoundProfilesProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => const []);

// Swipe action notifier
class SwipeNotifier extends StateNotifier<int> {
  SwipeNotifier() : super(0);

  void like() {
    state++;
  }

  void pass() {
    state++;
  }

  void superLike() {
    state++;
  }
}

