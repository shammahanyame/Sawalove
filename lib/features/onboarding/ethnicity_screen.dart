import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class EthnicityScreen extends StatefulWidget {
  const EthnicityScreen({super.key});

  @override
  State<EthnicityScreen> createState() => _EthnicityScreenState();
}

class _EthnicityScreenState extends State<EthnicityScreen> {
  String? _ethnicity;
  String? _language;

  final List<String> ethnicities = [
    'Bamileke',
    'Bassa',
    'Bakweri',
    'Bulu/Fang',
    'Douala',
    'Ewondo',
    'Fulani (Foulbé)',
    'Grassfields',
    'Kirdi',
    'Mbororo',
    'Gbaya',
    'Baka',
    'Other',
    'Prefer not to say',
  ];

  final List<String> languages = [
    'French',
    'English',
    'Pidgin',
    'Ewondo',
    'Duala',
    'Bamoun',
    'Fulfulde',
    'French + English',
    'Other',
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
                value: 0.6,
                backgroundColor: SawaLoveTheme.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation<Color>(SawaLoveTheme.primary),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
Icon(Icons.people, color: Theme.of(context).colorScheme.tertiary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Heritage',
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Optional - helps cultural matching',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: SawaLoveTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Ethnicity
              Text(
                'Ethnic Group',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _ethnicity,
decoration: const InputDecoration.collapsed(hintText: 'Tap to select'),
                  isExpanded: true,
                  items: ['None', ...ethnicities].map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 16)),
                  )).toList(),
                  onChanged: (value) => setState(() => _ethnicity = value),
                ),
              ),
              const SizedBox(height: 32),
              // Language
              Text(
                'Languages Spoken',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SawaLoveTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _language,
decoration: const InputDecoration.collapsed(hintText: 'Primary language'),
                  isExpanded: true,
                  items: ['None', ...languages].map((l) => DropdownMenuItem<String>(
                    value: l,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
child: const Icon(Icons.language, size: 16, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Text(l, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) => setState(() => _language = value),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/onboarding/photos'),
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
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/onboarding/photos'),
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

