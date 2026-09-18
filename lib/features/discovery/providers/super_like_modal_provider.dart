import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SuperLikeModalState { confirm, lastOne, sent, empty, premium }

class SuperLikeModalNotifier extends StateNotifier<SuperLikeModalState> {
  int _countdownSeconds = 0;

  SuperLikeModalNotifier() : super(SuperLikeModalState.confirm);

  int get countdownSeconds => _countdownSeconds;

  void setState(SuperLikeModalState newState) {
    state = newState;
  }

  void setSent() {
    state = SuperLikeModalState.sent;
  }

  void setEmpty() {
    state = SuperLikeModalState.empty;
  }

  void setPremium() {
    state = SuperLikeModalState.premium;
  }

  void setCountdown(int seconds) {
    _countdownSeconds = seconds;
  }
}

final superLikeModalProvider = StateNotifierProvider<SuperLikeModalNotifier, SuperLikeModalState>((ref) {
  return SuperLikeModalNotifier();
});

