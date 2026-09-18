import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RewindModalState {
  confirm,
  last,
  empty,
  premium,
}

final rewindModalProvider = StateNotifierProvider<RewindModalNotifier, RewindModalState>((ref) {
  return RewindModalNotifier();
});

class RewindModalNotifier extends StateNotifier<RewindModalState> {
  RewindModalNotifier() : super(RewindModalState.confirm);

  void setConfirm() => state = RewindModalState.confirm;
  void setLast() => state = RewindModalState.last;
  void setEmpty() => state = RewindModalState.empty;
  void setPremium() => state = RewindModalState.premium;
}
