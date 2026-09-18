import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/services/firebase_service.dart';

final userProvider = StreamProvider<User?>((ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  return firebase.authStateChanges;
});

final onboardingDataProvider = StateNotifierProvider<OnboardingNotifier, Map<String, dynamic>>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<Map<String, dynamic>> {
  OnboardingNotifier() : super({});

  void updateData(Map<String, dynamic> data) {
    state = {...state, ...data};
  }

  Future<void> saveProfile(Map<String, dynamic> data) async {
    final backend = FirebaseService();
    if (backend.currentUser != null) {
      await backend.saveUserProfile(backend.currentUser!.uid, data);
    }
  }
}

final profileCompletenessProvider = FutureProvider<double>((ref) async {
  // Calculate % from Firestore user doc
  return 0.4; // Stub - implement completeness logic
});

