import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final intentPickerProvider = StateNotifierProvider<IntentPickerNotifier, IntentPickerState>((ref) {
  return IntentPickerNotifier();
});

class IntentPickerState {
  final List<String> selectedIntents;
  final String visibilityMode;

  const IntentPickerState({
    this.selectedIntents = const [],
    this.visibilityMode = 'everyone',
  });

  bool get isValid => selectedIntents.isNotEmpty;

  IntentPickerState copyWith({
    List<String>? selectedIntents,
    String? visibilityMode,
  }) {
    return IntentPickerState(
      selectedIntents: selectedIntents ?? this.selectedIntents,
      visibilityMode: visibilityMode ?? this.visibilityMode,
    );
  }
}

class IntentPickerNotifier extends StateNotifier<IntentPickerState> {
  IntentPickerNotifier() : super(const IntentPickerState());

  void toggle(String intent) {
    final current = List<String>.from(state.selectedIntents);
    if (current.contains(intent)) {
      current.remove(intent);
    } else {
      current.add(intent);
    }
    state = state.copyWith(selectedIntents: current);
  }

  void setVisibility(String mode) {
    state = state.copyWith(visibilityMode: mode);
  }

  void skip() {
    state = const IntentPickerState();
  }

  void save(BuildContext context) {
    // stub save
  }
}

