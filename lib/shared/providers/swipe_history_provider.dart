import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/models/swipe_record.dart';

final swipeHistoryProvider = StateNotifierProvider<SwipeHistoryNotifier, SwipeHistoryState>((ref) {
  return SwipeHistoryNotifier();
});

class SwipeHistoryState {
  final List<SwipeRecord> records;
  final SwipeRecord? lastSwipe;

  const SwipeHistoryState({
    this.records = const [],
    this.lastSwipe,
  });

  SwipeHistoryState copyWith({
    List<SwipeRecord>? records,
    SwipeRecord? lastSwipe,
  }) {
    return SwipeHistoryState(
      records: records ?? this.records,
      lastSwipe: lastSwipe ?? this.lastSwipe,
    );
  }
}

class SwipeHistoryNotifier extends StateNotifier<SwipeHistoryState> {
  SwipeHistoryNotifier() : super(const SwipeHistoryState());

  void recordSwipe(SwipeRecord record) {
    state = state.copyWith(
      records: [...state.records, record],
      lastSwipe: record,
    );
  }

  void popLast() {
    if (state.records.isEmpty) return;
    final newRecords = List<SwipeRecord>.from(state.records)..removeLast();
    state = SwipeHistoryState(
      records: newRecords,
      lastSwipe: newRecords.isNotEmpty ? newRecords.last : null,
    );
  }

  void clear() {
    state = const SwipeHistoryState();
  }
}
