import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/services/firebase_service.dart';

final userProvider = StreamProvider<User?>((ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  return firebase.authStateChanges;
});

final onboardingDataProvider = StateNotifierProvider<OnboardingNotifier, Map<String, dynamic>>((ref) {
  return OnboardingNotifier(ref);
});

class OnboardingNotifier extends StateNotifier<Map<String, dynamic>> {
  OnboardingNotifier(this._ref) : super({});

  final Ref _ref;

  void updateData(Map<String, dynamic> data) {
    state = {...state, ...data};
  }

  /// Persists onboarding data to the API (`PUT /users/{id}`) and mirrors it
  /// into local state.
  ///
  /// The old implementation checked `currentUser` on a freshly constructed
  /// service before its session had loaded from storage, so the write
  /// silently no-oped for real users. We now wait for the first
  /// `authStateChanges` event (emitted after the session is loaded). Failures
  /// are swallowed: onboarding must never brick the flow, and Edit Profile
  /// can re-save later.
  Future<void> saveProfile(Map<String, dynamic> data) async {
    state = {...state, ...data};
    try {
      final backend = _ref.read(firebaseServiceProvider);
      if (!backend.isConfigured) return;
      final user = await backend.authStateChanges.first;
      if (user == null) return;
      await backend.saveUserProfile(user.uid, data);
    } catch (_) {
      // Best effort — see doc comment.
    }
  }
}

