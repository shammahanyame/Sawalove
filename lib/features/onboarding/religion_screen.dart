import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class ReligionScreen extends StatefulWidget {
  const ReligionScreen({super.key});

  @override
  State<ReligionScreen> createState() => _ReligionScreenState();
}

class _ReligionScreenState extends State<ReligionScreen> {
  String _denomination = '';
  String _frequency = '';

  final List<String> denominations = [
    'Christian - Catholic',
    'Christian - Protestant',
    'Christian - Pentecostal',
    'Muslim',
    'Traditional',
    'Other',
    'Prefer not to say',
  ];

  final List<String> frequencies = [
    'Daily',
    'Weekly',
    'Occasionally',
    'Rarely',
    'Not religious',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress
              const LinearProgressIndicator(
                value: 0.5,
                backgroundColor: SawaLoveTheme.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation<Color>(SawaLoveTheme.primary),
              ),
              const SizedBox(height: 48),
              Text(
                'Faith & Worship',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Church/Denomination helps us match you better',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: SawaLoveTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              // Denomination picker
              Text(
                'Denomination',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _denomination.isEmpty ? null : _denomination,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Select denomination',
                  ),
                  items: denominations.map((denom) => DropdownMenuItem(
                    value: denom,
                    child: Text(denom),
                  )).toList(),
                  onChanged: (value) => setState(() => _denomination = value ?? ''),
                ),
              ),
              const SizedBox(height: 32),
              // Frequency picker
              Text(
                'Church Attendance',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _frequency.isEmpty ? null : _frequency,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'How often?',
                  ),
                  items: frequencies.map((freq) => DropdownMenuItem(
                    value: freq,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.church,
                          size: 20,
                          color: SawaLoveTheme.tertiary,
                        ),
                        const SizedBox(width: 12),
                        Text(freq),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) => setState(() => _frequency = value ?? ''),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_denomination.isNotEmpty || _frequency.isNotEmpty)
                    ? () => context.go('/onboarding/next') // Photos/language/etc
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SawaLoveTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

