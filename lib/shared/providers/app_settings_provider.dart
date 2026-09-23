import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _preferredLanguageKey = 'preferred_language';
const _preferredRegionKey = 'preferred_region';
const _themeModeKey = 'theme_mode';

class AppSettings {
  final Locale locale;
  final String region;
  final ThemeMode themeMode;
  final bool isLoaded;

  const AppSettings({
    required this.locale,
    required this.region,
    this.themeMode = ThemeMode.system,
    this.isLoaded = false,
  });

  const AppSettings.initial()
      : locale = const Locale('en'),
        region = 'Cameroon',
        themeMode = ThemeMode.system,
        isLoaded = false;

  AppSettings copyWith({
    Locale? locale,
    String? region,
    ThemeMode? themeMode,
    bool? isLoaded,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      region: region ?? this.region,
      themeMode: themeMode ?? this.themeMode,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings.initial()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_preferredLanguageKey) ?? 'en';
      final region = prefs.getString(_preferredRegionKey) ?? 'Cameroon';
      final themeModeIndex = prefs.getInt(_themeModeKey);

      state = AppSettings(
        locale: Locale(languageCode),
        region: region,
        themeMode: themeModeIndex == null
            ? ThemeMode.system
            : ThemeMode.values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)],
        isLoaded: true,
      );
    } catch (_) {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale, isLoaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredLanguageKey, locale.languageCode);
  }

  Future<void> setRegion(String region) async {
    state = state.copyWith(region: region, isLoaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredRegionKey, region);
  }

  Future<void> update({
    required Locale locale,
    required String region,
  }) async {
    state = state.copyWith(locale: locale, region: region, isLoaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredLanguageKey, locale.languageCode);
    await prefs.setString(_preferredRegionKey, region);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode, isLoaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);
