import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/app_settings_provider.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  final bool fromSettings;
  final VoidCallback? onSettingsChange;

  const LanguageSelectionScreen({
    super.key,
    this.fromSettings = false,
    this.onSettingsChange,
  });

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  Locale _selectedLocale = const Locale('en');
  late final Locale _suggestedLocale;

  @override
  void initState() {
    super.initState();
    _detectSuggestedLocale();
  }

  void _detectSuggestedLocale() {
    final systemLocale = Platform.localeName;
    _suggestedLocale =
        systemLocale.startsWith('fr') ? const Locale('fr') : const Locale('en');
    setState(() => _selectedLocale = _suggestedLocale);
  }

  Future<void> _confirmLanguage(Locale locale) async {
    try {
      await ref.read(appSettingsProvider.notifier).setLocale(locale);

      if (!mounted) return;
      if (widget.fromSettings) {
        widget.onSettingsChange?.call();
        context.pop();
      } else {
        context.go('/login');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save preference — please try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Hero Bar (hidden in settings mode)
            if (!widget.fromSettings)
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB30065), Color(0xFFFF6EA9)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'SawaLove',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Breadcrumb (settings mode only)
                      if (widget.fromSettings)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: SawaLoveTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.settings, size: 16),
                              SizedBox(width: 8),
                              Text('Settings › Language'),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Progress Dots (first install only)
                      if (!widget.fromSettings)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 12, height: 12, decoration: const BoxDecoration(color: SawaLoveTheme.outlineVariant, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Container(width: 20, height: 12, decoration: const BoxDecoration(color: Color(0xFFB30065), borderRadius: BorderRadius.horizontal(left: Radius.circular(6), right: Radius.circular(6)))),
                            const SizedBox(width: 8),
                            Container(width: 12, height: 12, decoration: const BoxDecoration(color: SawaLoveTheme.outlineVariant, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Container(width: 12, height: 12, decoration: const BoxDecoration(color: SawaLoveTheme.outlineVariant, shape: BoxShape.circle)),
                          ],
                        ),
                      const SizedBox(height: 48),
                      // Headline
                      const Text(
                        'Choose your language / Choisissez votre langue',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 48),
                      // Language Cards
                      _LanguageCard(
                        locale: const Locale('en'),
                        isSelected: _selectedLocale.languageCode == 'en',
                        flagLabel: 'EN',
                        nativeName: 'English',
                        regionalVariant: 'Default',
                        badgeText: 'Default',
                        onTap: () => setState(() => _selectedLocale = const Locale('en')),
                      ),
                      const SizedBox(height: 16),
                      _LanguageCard(
                        locale: const Locale('fr'),
                        isSelected: _selectedLocale.languageCode == 'fr',
                        flagLabel: 'FR',
                        nativeName: 'Français',
                        regionalVariant: 'International',
                        badgeText: _selectedLocale.languageCode == 'fr' ? 'Sélectionné' : 'Popular',
                        onTap: () => setState(() => _selectedLocale = const Locale('fr')),
                      ),
                      const SizedBox(height: 32),
                      // Divider + Detect
                      if (!widget.fromSettings)
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: SawaLoveTheme.outlineVariant)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('Detect from location', style: TextStyle(color: SawaLoveTheme.onSurfaceVariant, fontSize: 12)),
                                ),
                                Expanded(child: Container(height: 1, color: SawaLoveTheme.outlineVariant)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => _detectSuggestedLocale(),
                              icon: const Icon(Icons.location_on, size: 20),
                              label: Text('${_suggestedLocale.languageCode.toUpperCase()} suggested'),
                            ),
                          ],
                        ),
                      const SizedBox(height: 48),
                      // CTA
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB30065),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            elevation: 8,
                          ),
                          onPressed: () => _confirmLanguage(_selectedLocale),
                          child: Text(
                            _selectedLocale.languageCode == 'en' ? 'Continue in English' : 'Continuer en Français',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Locale locale;
  final bool isSelected;
  final String flagLabel;
  final String nativeName;
  final String regionalVariant;
  final String badgeText;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.locale,
    required this.isSelected,
    required this.flagLabel,
    required this.nativeName,
    required this.regionalVariant,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isSelected
        ? 'English — tap to select English as your app language'
        : 'Français — appuyez pour sélectionner le français comme langue de l\'application',
      checked: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFFB30065) : const Color(0xFFFFD1E1),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? const Color(0xFFFFF4F6) : Colors.white,
          ),
          child: Row(
            children: [
              // Radio circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SawaLoveTheme.outlineVariant),
                ),
                child: isSelected
                  ? const Icon(Icons.radio_button_checked, size: 20, color: Color(0xFFB30065))
                  : Container(),
              ),
              const SizedBox(width: 16),
              // Flag
              CircleAvatar(
                radius: 16,
                backgroundColor: isSelected ? const Color(0xFFB30065) : const Color(0xFFFFD1E1),
                child: Text(
                  flagLabel,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8329C8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Language text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nativeName,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      regionalVariant,
                      style: const TextStyle(
                        fontFamily: 'BeVietnamPro',
                        fontSize: 13,
                        color: Color(0xFF9C677D),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8329C8) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF9C677D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

