import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _preferredLanguageKey = 'preferred_language';
const _preferredRegionKey = 'preferred_region';

class AppSettings {
  final Locale locale;
  final String region;
  final bool isLoaded;

  const AppSettings({
    required this.locale,
    required this.region,
    this.isLoaded = false,
  });

  const AppSettings.initial()
      : locale = const Locale('en'),
        region = 'Cameroon',
        isLoaded = false;

  AppSettings copyWith({
    Locale? locale,
    String? region,
    bool? isLoaded,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      region: region ?? this.region,
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

      state = AppSettings(
        locale: Locale(languageCode),
        region: region,
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
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);
