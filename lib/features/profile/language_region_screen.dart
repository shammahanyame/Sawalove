import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/providers/app_settings_provider.dart';

class LanguageRegionScreen extends ConsumerStatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  ConsumerState<LanguageRegionScreen> createState() =>
      _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends ConsumerState<LanguageRegionScreen> {
  String _languageCode = 'en';
  String _region = 'Cameroon';
  bool _initialized = false;
  bool _isSaving = false;

  static const Map<String, String> _languageLabels = {
    'en': 'English',
    'fr': 'Francais',
  };

  static const List<String> _regions = [
    'Cameroon',
    'France',
    'USA',
    'UK',
    'Canada',
    'Germany',
  ];

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(appSettingsProvider.notifier).update(
            locale: Locale(_languageCode),
            region: _region,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Language & region updated')),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save settings. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    if (!_initialized && settings.isLoaded) {
      _languageCode = settings.locale.languageCode;
      _region = settings.region;
      _initialized = true;
    }

    final languageLabel = _languageLabels[_languageCode] ?? 'English';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language & Region'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Language',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: _languageCode,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _languageCode = value);
                  }
                },
                child: const Column(
                  children: [
                    Card(
                      child: RadioListTile<String>(
                        title: Text('English'),
                        subtitle: Text('Default'),
                        value: 'en',
                      ),
                    ),
                    Card(
                      child: RadioListTile<String>(
                        title: Text('Francais'),
                        subtitle: Text('Francais du Cameroun'),
                        value: 'fr',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Content Region',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Card(
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_region),
                    initialValue: _region,
                    decoration: const InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(),
                    ),
                    items: _regions
                        .map(
                          (region) => DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _region = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preview',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SawaLoveTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Language: $languageLabel'),
                            Text('Region: $_region'),
                            const SizedBox(height: 12),
                            Text(
                              _languageCode == 'fr'
                                  ? 'Bonjour Amaka! Bienvenue sur SawaLove.'
                                  : 'Hello Amaka! Welcome to SawaLove.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
