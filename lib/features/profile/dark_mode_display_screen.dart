import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/providers/app_settings_provider.dart';

class DarkModeDisplayScreen extends ConsumerStatefulWidget {
  const DarkModeDisplayScreen({super.key});

  @override
  ConsumerState<DarkModeDisplayScreen> createState() => _DarkModeDisplayScreenState();
}

class _DarkModeDisplayScreenState extends ConsumerState<DarkModeDisplayScreen> {
  late ThemeMode _themeMode = ref.read(appSettingsProvider).themeMode;
  double _textScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display & Theme'),
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
                'Theme',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: RadioGroup<ThemeMode>(
                    groupValue: _themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _themeMode = value);
                        // Persist immediately so the change is not lost.
                        ref.read(appSettingsProvider.notifier).setThemeMode(value);
                      }
                    },
                    child: Column(
                      children: [
                        const RadioListTile<ThemeMode>(
                          title: Text('System'),
                          subtitle: Text('Follow device setting'),
                          value: ThemeMode.system,
                        ),
                        RadioListTile<ThemeMode>(
                          title: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1A0B1D),
                                      Color(0xFF2D1B3A)
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('Dark'),
                            ],
                          ),
                          subtitle: const Text('Berry dark mode'),
                          value: ThemeMode.dark,
                        ),
                        const RadioListTile<ThemeMode>(
                          title: Row(
                            children: [
                              Icon(Icons.sunny, color: SawaLoveTheme.primary),
                              SizedBox(width: 12),
                              Text('Light'),
                            ],
                          ),
                          subtitle: Text('Sunset blush light'),
                          value: ThemeMode.light,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Text Size',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Slider(
                        value: _textScale,
                        min: 0.8,
                        max: 1.5,
                        divisions: 14,
                        label: '${(_textScale * 100).round()}%',
                        onChanged: (value) =>
                            setState(() => _textScale = value),
                      ),
                      Text(
                        'Preview:',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(_textScale)),
                        child: Text(
                          'Loving life in Douala. Catholic from Littoral region. Looking for serious relationship.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Dynamic type
              SwitchListTile(
                title: const Text('Dynamic Text Size'),
                subtitle: const Text('Respect device accessibility settings'),
                value: true,
                onChanged: (v) {},
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Preview Theme',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _themeMode == ThemeMode.dark
                              ? const Color(0xFF1A0B1D)
                              : SawaLoveTheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.heart_broken,
                              size: 48,
                              color: _themeMode == ThemeMode.dark
                                  ? const Color(0xFFFF6EA9)
                                  : SawaLoveTheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'SawaLove',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    color: _themeMode == ThemeMode.dark
                                        ? Colors.white
                                        : SawaLoveTheme.primary,
                                  ),
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
                onPressed: () {
                  ref.read(appSettingsProvider.notifier).setThemeMode(_themeMode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Display settings updated')),
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
