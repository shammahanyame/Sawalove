import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesState {
  final int ageMin;
  final int ageMax;
  final double distanceKm;
  final Set<String> genders;
  final Set<String> intents;
  final Set<String> religions;
  final Map<String, bool> dealbreakers;
  final bool openToAll;

  const PreferencesState({
    this.ageMin = 22,
    this.ageMax = 35,
    this.distanceKm = 25,
    this.genders = const {},
    this.intents = const {},
    this.religions = const {},
    this.dealbreakers = const {},
    this.openToAll = false,
  });

  PreferencesState copyWith({
    int? ageMin,
    int? ageMax,
    double? distanceKm,
    Set<String>? genders,
    Set<String>? intents,
    Set<String>? religions,
    Map<String, bool>? dealbreakers,
    bool? openToAll,
  }) {
    return PreferencesState(
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      distanceKm: distanceKm ?? this.distanceKm,
      genders: genders ?? this.genders,
      intents: intents ?? this.intents,
      religions: religions ?? this.religions,
      dealbreakers: dealbreakers ?? this.dealbreakers,
      openToAll: openToAll ?? this.openToAll,
    );
  }

  static const int _totalUserBase = 5000;

  int get estimatedPoolCount {
    if (openToAll) return _totalUserBase;
    var pool = _totalUserBase.toDouble();
    final ageSpan = ageMax - ageMin;
    if (ageSpan < 42) pool *= ageSpan / 42;
    if (distanceKm < 500) pool *= distanceKm / 500;
    if (genders.isNotEmpty && !genders.contains('everyone')) {
      pool *= genders.length / 4;
    }
    if (intents.isNotEmpty) pool *= intents.length / 5;
    if (religions.isNotEmpty && !religions.contains('any_faith')) {
      pool *= religions.length / 5;
    }
    if (dealbreakers['children'] == true) pool *= 0.7;
    if (dealbreakers['smokes'] == true) pool *= 0.85;
    if (dealbreakers['unverified'] == true) pool *= 0.6;
    return pool.clamp(10, _totalUserBase).toInt();
  }

  double get poolFraction => estimatedPoolCount / _totalUserBase;

  String get poolSubLabel {
    if (estimatedPoolCount < 100) return 'Very narrow pool';
    if (estimatedPoolCount < 500) return 'Narrow pool';
    return 'Good range';
  }

  String? get wideningSuggestion {
    if (estimatedPoolCount >= 100) return null;
    if (distanceKm < 100) return 'Increasing distance to 100 km may improve results.';
    return 'Relaxing one deal-breaker may improve your pool.';
  }

  String get distanceLabel {
    if (distanceKm >= 500) return "Anywhere / N'importe ou";
    return '${distanceKm.toInt()} km';
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier() : super(const PreferencesState());

  void setAgeRange(int min, int max) {
    if (max - min < 3) {
      if (max < 60) {
        max = min + 3;
      } else {
        min = max - 3;
      }
    }
    state = state.copyWith(
      ageMin: min.clamp(18, 60),
      ageMax: max.clamp(18, 60),
    );
  }

  void setDistance(double km) => state = state.copyWith(distanceKm: km.clamp(1, 500));

  void toggleGender(String gender) => state = state.copyWith(genders: _toggle(state.genders, gender, exclusive: 'everyone'));

  void toggleIntent(String intent) => state = state.copyWith(intents: _toggle(state.intents, intent));

  void toggleReligion(String religion) => state = state.copyWith(religions: _toggle(state.religions, religion, exclusive: 'any_faith'));

  void toggleDealbreaker(String key) {
    final next = Map<String, bool>.from(state.dealbreakers);
    next[key] = !(next[key] ?? false);
    state = state.copyWith(dealbreakers: next);
  }

  void setOpenToAll(bool value) => state = state.copyWith(openToAll: value);

  void applyDemoState(String stateName) {
    switch (stateName) {
      case 'preferences_set':
        state = const PreferencesState(
          ageMin: 24,
          ageMax: 34,
          distanceKm: 50,
          genders: {'women'},
          intents: {'serious', 'marriage'},
          religions: {'christian'},
        );
        break;
      case 'strict':
        state = const PreferencesState(
          ageMin: 28,
          ageMax: 30,
          distanceKm: 10,
          genders: {'women'},
          intents: {'marriage'},
          religions: {'christian'},
        );
        break;
      case 'dealbreakers':
        state = const PreferencesState(
          dealbreakers: {'children': true, 'smokes': true, 'unverified': true},
        );
        break;
      case 'open_to_all':
        state = const PreferencesState(openToAll: true);
        break;
      default:
        state = const PreferencesState();
    }
  }

  Future<void> savePreferences(String uid) async {}

  Set<String> _toggle(Set<String> source, String value, {String? exclusive}) {
    final next = Set<String>.from(source);
    if (exclusive != null && value == exclusive) {
      return next.contains(value) ? <String>{} : <String>{value};
    }
    if (exclusive != null) next.remove(exclusive);
    next.contains(value) ? next.remove(value) : next.add(value);
    return next;
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, PreferencesState>(
  (ref) => PreferencesNotifier(),
);
