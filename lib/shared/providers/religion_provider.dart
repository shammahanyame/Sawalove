import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _unset = Object();

class Religion {
  final String id;
  final String name;
  final String nameFr;
  final bool hasDenominations;
  final List<Denomination> denominations;

  const Religion({
    required this.id,
    required this.name,
    required this.nameFr,
    required this.hasDenominations,
    this.denominations = const [],
  });

  factory Religion.fromJson(Map<String, dynamic> json) {
    final rawDenominations = json['denominations'];
    final denominations = rawDenominations is List
        ? rawDenominations
            .whereType<Map>()
            .map(
              (item) => Denomination.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <Denomination>[];
    final name = json['name'] as String? ?? '';

    return Religion(
      id: json['id'] as String? ?? '',
      name: name,
      nameFr: json['nameFr'] as String? ?? name,
      hasDenominations:
          json['hasDenominations'] as bool? ?? denominations.isNotEmpty,
      denominations: denominations,
    );
  }
}

class Denomination {
  final String id;
  final String name;
  final String nameFr;

  const Denomination({
    required this.id,
    required this.name,
    required this.nameFr,
  });

  factory Denomination.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    return Denomination(
      id: json['id'] as String? ?? '',
      name: name,
      nameFr: json['nameFr'] as String? ?? name,
    );
  }
}

class ReligionState {
  final String? selectedReligion;
  final Set<String> selectedDenominations;
  final String? practiceFrequency;
  final String customChurchName;
  final bool profileVisible;
  final bool preferNotToSay;

  const ReligionState({
    this.selectedReligion,
    this.selectedDenominations = const {},
    this.practiceFrequency,
    this.customChurchName = '',
    this.profileVisible = true,
    this.preferNotToSay = false,
  });

  bool get isComplete => preferNotToSay || selectedReligion != null;

  ReligionState copyWith({
    Object? selectedReligion = _unset,
    Set<String>? selectedDenominations,
    Object? practiceFrequency = _unset,
    String? customChurchName,
    bool? profileVisible,
    bool? preferNotToSay,
  }) {
    return ReligionState(
      selectedReligion: identical(selectedReligion, _unset)
          ? this.selectedReligion
          : selectedReligion as String?,
      selectedDenominations:
          selectedDenominations ?? this.selectedDenominations,
      practiceFrequency: identical(practiceFrequency, _unset)
          ? this.practiceFrequency
          : practiceFrequency as String?,
      customChurchName: customChurchName ?? this.customChurchName,
      profileVisible: profileVisible ?? this.profileVisible,
      preferNotToSay: preferNotToSay ?? this.preferNotToSay,
    );
  }
}

class ReligionNotifier extends StateNotifier<ReligionState> {
  ReligionNotifier() : super(ReligionState());

  Future<List<Religion>> loadReligions() async {
    final response = await rootBundle.loadString('assets/data/religions.json');
    final data = json.decode(response);
    if (data is! List) {
      throw const FormatException('Religion data must be a JSON list.');
    }
    return data
        .whereType<Map>()
        .map(
          (item) => Religion.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  void selectReligion(String? id) {
    if (id == null) return;
    if (state.selectedReligion == id) {
      // Deselect
      state = state.copyWith(
        selectedReligion: null,
        selectedDenominations: {},
        practiceFrequency: null,
        customChurchName: '',
      );
    } else {
      state = state.copyWith(
        selectedReligion: id,
        selectedDenominations: {},
        practiceFrequency: null,
        customChurchName: '',
      );
    }
  }

  void toggleDenomination(String denomId) {
    final denoms = Set<String>.from(state.selectedDenominations);
    if (denoms.contains(denomId)) {
      denoms.remove(denomId);
    } else {
      denoms.add(denomId);
    }
    state = state.copyWith(selectedDenominations: denoms);
  }

  void selectFrequency(String freq) {
    state = state.copyWith(practiceFrequency: freq);
  }

  void setCustomChurch(String name) {
    state = state.copyWith(customChurchName: name);
  }

  void togglePreferNotToSay() {
    final newVal = !state.preferNotToSay;
    state = state.copyWith(
      preferNotToSay: newVal,
      selectedReligion: newVal ? null : state.selectedReligion,
      profileVisible: !newVal,
    );
  }

  void toggleProfileVisible() {
    if (!state.preferNotToSay) {
      state = state.copyWith(profileVisible: !state.profileVisible);
    }
  }

  void clear() {
    state = ReligionState();
  }
}

final religionsProvider = FutureProvider<List<Religion>>((ref) {
  final notifier = ref.read(religionNotifierProvider.notifier);
  return notifier.loadReligions();
});

final religionNotifierProvider =
    StateNotifierProvider<ReligionNotifier, ReligionState>((ref) {
  return ReligionNotifier();
});
