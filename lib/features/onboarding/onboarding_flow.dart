import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sawalove/shared/providers/user_provider.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  int currentStep = 0;
  bool _saving = false;
  final Map<String, dynamic> profileData = {};

  /// Merges step data into [profileData]. `preferences` maps are merged
  /// key-by-key so two controls in the same step don't overwrite each other.
  void _onData(Map<String, dynamic> data) {
    final incomingPrefs = data['preferences'];
    if (incomingPrefs is Map) {
      final existing = profileData['preferences'];
      data = {
        ...data,
        'preferences': {
          if (existing is Map) ...existing,
          ...incomingPrefs,
        },
      };
    }
    profileData.addAll(data);
  }

  List<Widget> get pages => [
        _NameStep(initial: profileData, onDataChanged: _onData),
        _PersonalInfoStep(initial: profileData, onDataChanged: _onData),
        _LocationStep(initial: profileData, onDataChanged: _onData),
        _ChurchIntentStep(initial: profileData, onDataChanged: _onData),
      ];

  Future<void> nextStep() async {
    if (currentStep == 0 &&
        (profileData['name'] ?? '').toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    if (currentStep < pages.length - 1) {
      setState(() => currentStep++);
      return;
    }

    // Final step: persist everything to the API (`PUT /users/{id}`) before
    // moving on. The old flow only wrote to a local provider, so onboarding
    // answers silently never reached the server.
    setState(() => _saving = true);
    await ref.read(onboardingDataProvider.notifier).saveProfile(profileData);
    if (!mounted) return;
    context.go('/onboarding/photos');
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  double get progress => (currentStep + 1) / pages.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 24),
            Expanded(child: pages[currentStep]),
            const SizedBox(height: 48),
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  if (currentStep > 0)
                    TextButton(
                      onPressed: previousStep,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saving ? null : nextStep,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(currentStep < pages.length - 1
                            ? 'Next'
                            : 'Continue to Verification'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Step widgets

class _NameStep extends StatefulWidget {
  final Map<String, dynamic> initial;
  final Function(Map<String, dynamic>) onDataChanged;
  const _NameStep({required this.initial, required this.onDataChanged});

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  late final TextEditingController _controller =
      TextEditingController(text: (widget.initial['name'] ?? '').toString());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about yourself',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.onDataChanged({'name': value}),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoStep extends StatefulWidget {
  final Map<String, dynamic> initial;
  final Function(Map<String, dynamic>) onDataChanged;
  const _PersonalInfoStep({required this.initial, required this.onDataChanged});

  @override
  State<_PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<_PersonalInfoStep> {
  DateTime? _dob;

  static const _dobKey = 'sawalove.declared_dob_iso';

  @override
  void initState() {
    super.initState();
    _seedDob();
  }

  Future<void> _seedDob() async {
    // The age gate already collected this; reuse it so the user is not asked
    // for the same date twice.
    final fromFlow = widget.initial['dob'];
    if (fromFlow is String) {
      final parsed = DateTime.tryParse(fromFlow);
      if (parsed != null) {
        setState(() => _dob = parsed);
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_dobKey);
    if (stored == null || !mounted) return;
    final parsed = DateTime.tryParse(stored);
    if (parsed != null) setState(() => _dob = parsed);
  }

  int? get _age {
    final dob = _dob;
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100, 1, 1),
      // 18+ enforced: this is also what the age gate verified.
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (picked == null || !mounted) return;
    setState(() => _dob = picked);
    widget.onDataChanged({
      'dob': picked.toIso8601String(),
      'age': _age,
    });
  }

  String _format(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final age = _age;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Info',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Your age is shown on your profile. You must be 18 or older.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_outlined),
            title: Text(
              _dob == null ? 'Select your date of birth' : _format(_dob!),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: age == null ? null : Text('Age: $age'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: _pickDob,
          ),
        ],
      ),
    );
  }
}

class _LocationStep extends StatefulWidget {
  final Map<String, dynamic> initial;
  final Function(Map<String, dynamic>) onDataChanged;
  const _LocationStep({required this.initial, required this.onDataChanged});

  @override
  State<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<_LocationStep> {
  static const _regions = [
    'Littoral',
    'Centre',
    'West',
    'Southwest',
    'Northwest',
    'Adamawa',
    'East',
    'Far North',
  ];

  late final TextEditingController _villageController =
      TextEditingController(text: (widget.initial['village'] ?? '').toString());
  late String _region = (widget.initial['location'] ?? '').toString();

  @override
  void dispose() {
    _villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Where are you from?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Hometown / Region — shown on your discovery card.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _villageController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Hometown / Village',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.onDataChanged({'village': value}),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _region.isEmpty ? null : _region,
            decoration: const InputDecoration(
              labelText: 'Region',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('Not set')),
              for (final region in _regions)
                DropdownMenuItem(value: region, child: Text(region)),
            ],
            onChanged: (value) {
              setState(() => _region = value ?? '');
              widget.onDataChanged({'location': value ?? ''});
            },
          ),
        ],
      ),
    );
  }
}

class _ChurchIntentStep extends StatefulWidget {
  final Map<String, dynamic> initial;
  final Function(Map<String, dynamic>) onDataChanged;
  const _ChurchIntentStep({required this.initial, required this.onDataChanged});

  @override
  State<_ChurchIntentStep> createState() => _ChurchIntentStepState();
}

class _ChurchIntentStepState extends State<_ChurchIntentStep> {
  static const _churches = [
    'Catholic',
    'Protestant',
    'Pentecostal',
    'Baptist',
    'Presbyterian',
  ];
  static const _languages = ['English', 'French', 'Pidgin'];
  static const _intents = [
    'Serious relationship / Relation sérieuse',
    'Marriage / Mariage',
    'Friendship / Amitié',
    'Just chatting / Simple discussion',
  ];

  String _church = '';
  final Set<String> _languagesSelected = {};
  String _intent = '';

  @override
  void initState() {
    super.initState();
    final prefs = widget.initial['preferences'];
    if (prefs is Map) {
      _church = (prefs['religion'] ?? '').toString();
      final langs = prefs['languages'];
      if (langs is List) {
        _languagesSelected.addAll(langs.map((e) => e.toString()));
      }
    }
    _intent = (widget.initial['intent'] ?? '').toString();
  }

  void _reportPreferences() {
    widget.onDataChanged({
      'preferences': {
        'religion': _church,
        'languages': _languagesSelected.toList(),
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Community',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _church.isEmpty ? null : _church,
            decoration: const InputDecoration(
              labelText: 'Church / Denomination',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('Not set')),
              for (final church in _churches)
                DropdownMenuItem(value: church, child: Text(church)),
            ],
            onChanged: (value) {
              setState(() => _church = value ?? '');
              _reportPreferences();
            },
          ),
          const SizedBox(height: 24),
          const Text('Languages',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final language in _languages)
                FilterChip(
                  label: Text(language),
                  selected: _languagesSelected.contains(language),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _languagesSelected.add(language);
                      } else {
                        _languagesSelected.remove(language);
                      }
                    });
                    _reportPreferences();
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Relationship intent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _intent,
            onChanged: (value) {
              setState(() => _intent = value ?? '');
              widget.onDataChanged({'intent': value ?? ''});
            },
            child: Column(
              children: [
                for (final intent in _intents)
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: intent,
                    title: Text(intent),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
