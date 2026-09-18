import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Family provider keyed by profileUid that tracks whether the current user has liked that profile.
final likeProvider = StateNotifierProvider.family<LikeNotifier, bool, String>(
  (ref, profileUid) => LikeNotifier(),
);

class LikeNotifier extends StateNotifier<bool> {
  LikeNotifier() : super(false);

  void setLiked(bool liked) => state = liked;

  void like() {
    if (!state) {
      state = true;
      HapticFeedback.mediumImpact();
    }
  }

  void unlike() => state = false;

  void toggle() {
    state = !state;
    if (state) HapticFeedback.mediumImpact();
  }
}

