import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterPreset {
  final String name;
  final FilterState filters;

  const FilterPreset({required this.name, required this.filters});
}

class FilterPill {
  final String key;
  final String label;

  const FilterPill(this.key, this.label);
}

class FilterState {
  final int ageMin;
  final int ageMax;
  final double distanceKm;
  final Set<String> genders;
  final Set<String> intents;
  final Set<String> faiths;
  final Set<String> regions;
  final Set<String> lifestyles;
  final bool onlineNow;
  final bool withPhoto;
  final bool isPremium;
  final bool wasApplied;
  final List<FilterPreset> presets;

  const FilterState({
    this.ageMin = 22,
    this.ageMax = 35,
    this.distanceKm = 25,
    this.genders = const {},
    this.intents = const {},
    this.faiths = const {},
    this.regions = const {},
    this.lifestyles = const {},
    this.onlineNow = false,
    this.withPhoto = true,
    this.isPremium = false,
    this.wasApplied = false,
    this.presets = const [],
  });

  bool get hasActiveFilters => activeFilterCount > 0;

  int get activeFilterCount => activePills.length;

  String get ageRangeLabel => '$ageMin-$ageMax';

  String get distanceLabel => distanceKm >= 500 ? 'Anywhere' : '${distanceKm.toInt()} km';

  int get estimatedPoolCount {
    var pool = 5000.0;
    pool *= ((ageMax - ageMin).clamp(3, 42) / 42);
    pool *= (distanceKm.clamp(1, 500) / 500);
    if (genders.isNotEmpty) pool *= genders.length / 4;
    if (intents.isNotEmpty) pool *= intents.length / 5;
    if (faiths.isNotEmpty) pool *= faiths.length / 6;
    if (regions.isNotEmpty) pool *= regions.length / 10;
    if (onlineNow) pool *= 0.35;
    if (withPhoto) pool *= 0.85;
    return pool.clamp(20, 5000).toInt();
  }

  double get poolFraction => estimatedPoolCount / 5000;

  String get poolSubLabel => estimatedPoolCount < 100 ? 'Very narrow pool' : 'Good range';

  String? get wideningSuggestion {
    if (estimatedPoolCount >= 100) return null;
    if (distanceKm < 100) return 'Try increasing distance to 100 km.';
    return 'Try relaxing one or two filters.';
  }

  List<FilterPill> get activePills {
    final pills = <FilterPill>[];
    if (ageMin != 22 || ageMax != 35) pills.add(FilterPill('age', 'Age $ageMin-$ageMax'));
    if (distanceKm != 25) pills.add(FilterPill('distance', distanceLabel));
    for (final value in genders) {
      pills.add(FilterPill('gender:$value', value));
    }
    for (final value in intents) {
      pills.add(FilterPill('intent:$value', value));
    }
    for (final value in faiths) {
      pills.add(FilterPill('faith:$value', value));
    }
    for (final value in regions) {
      pills.add(FilterPill('region:$value', value));
    }
    for (final value in lifestyles) {
      pills.add(FilterPill('lifestyle:$value', value));
    }
    if (onlineNow) pills.add(const FilterPill('onlineNow', 'Online now'));
    if (!withPhoto) pills.add(const FilterPill('withPhoto', 'No photo required'));
    return pills;
  }

  FilterState copyWith({
    int? ageMin,
    int? ageMax,
    double? distanceKm,
    Set<String>? genders,
    Set<String>? intents,
    Set<String>? faiths,
    Set<String>? regions,
    Set<String>? lifestyles,
    bool? onlineNow,
    bool? withPhoto,
    bool? isPremium,
    bool? wasApplied,
    List<FilterPreset>? presets,
  }) {
    return FilterState(
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      distanceKm: distanceKm ?? this.distanceKm,
      genders: genders ?? this.genders,
      intents: intents ?? this.intents,
      faiths: faiths ?? this.faiths,
      regions: regions ?? this.regions,
      lifestyles: lifestyles ?? this.lifestyles,
      onlineNow: onlineNow ?? this.onlineNow,
      withPhoto: withPhoto ?? this.withPhoto,
      isPremium: isPremium ?? this.isPremium,
      wasApplied: wasApplied ?? this.wasApplied,
      presets: presets ?? this.presets,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  FilterState? _snapshot;

  bool get wasApplied => state.wasApplied;

  void saveSnapshot() => _snapshot = state;

  void restore([FilterState? filters]) => state = filters ?? _snapshot ?? state;

  void setApplied(bool value) => state = state.copyWith(wasApplied: value);

  void setAgeRange(int min, int max) => state = state.copyWith(ageMin: min, ageMax: max);

  void setDistance(double km) => state = state.copyWith(distanceKm: km);

  void toggleGender(String value) => state = state.copyWith(genders: _toggle(state.genders, value));

  void toggleIntent(String value) => state = state.copyWith(intents: _toggle(state.intents, value));

  void toggleFaith(String value) => state = state.copyWith(faiths: _toggle(state.faiths, value));

  void toggleRegion(String value) => state = state.copyWith(regions: _toggle(state.regions, value));

  void toggleLifestyle(String value) => state = state.copyWith(lifestyles: _toggle(state.lifestyles, value));

  void setOnlineNow(bool value) => state = state.copyWith(onlineNow: value);

  void setWithPhoto(bool value) => state = state.copyWith(withPhoto: value);

  void clearAll() => state = FilterState(presets: state.presets, isPremium: state.isPremium);

  void reset() => clearAll();

  void savePreset(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      presets: [
        ...state.presets,
        FilterPreset(name: trimmed, filters: state),
      ],
    );
  }

  void loadPreset(FilterPreset preset) {
    state = preset.filters.copyWith(presets: state.presets);
  }

  void removeFilter(String key) {
    if (key == 'age') {
      setAgeRange(22, 35);
    } else if (key == 'distance') {
      setDistance(25);
    } else if (key == 'onlineNow') {
      setOnlineNow(false);
    } else if (key == 'withPhoto') {
      setWithPhoto(true);
    } else if (key.startsWith('gender:')) {
      toggleGender(key.substring(7));
    } else if (key.startsWith('intent:')) {
      toggleIntent(key.substring(7));
    } else if (key.startsWith('faith:')) {
      toggleFaith(key.substring(6));
    } else if (key.startsWith('region:')) {
      toggleRegion(key.substring(7));
    } else if (key.startsWith('lifestyle:')) {
      toggleLifestyle(key.substring(10));
    }
  }

  Set<String> _toggle(Set<String> source, String value) {
    final next = Set<String>.from(source);
    next.contains(value) ? next.remove(value) : next.add(value);
    return next;
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);
