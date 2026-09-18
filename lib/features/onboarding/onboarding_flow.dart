import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/shared/providers/user_provider.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  int currentStep = 0;
  final Map<String, dynamic> profileData = {};

  List<Widget> get pages => [
    _NameStep(onDataChanged: (data) => profileData.addAll(data)),
    _PersonalInfoStep(onDataChanged: (data) => profileData.addAll(data)),
    _LocationStep(onDataChanged: (data) => profileData.addAll(data)),
    _ChurchIntentStep(onDataChanged: (data) => profileData.addAll(data)),
  ];

  void nextStep() {
    if (currentStep < pages.length - 1) {
      setState(() => currentStep++);
    } else {
      // Save profile
      ref.read(onboardingDataProvider.notifier).saveProfile(profileData);
      context.go('/onboarding/photos');
    }
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
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 24),
            Expanded(child: pages[currentStep]),
            const SizedBox(height: 48),
            // Navigation Buttons
            Row(
              children: [
                if (currentStep > 0)
                  TextButton(
                    onPressed: previousStep,
                    child: const Text('Back'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: nextStep,
                  child: Text(currentStep < pages.length - 1 ? 'Next' : 'Continue to Verification'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Step widgets
class _NameStep extends StatelessWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  const _NameStep({required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Tell us about yourself', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
          ),
          TextButton(onPressed: () => onDataChanged({'name': nameController.text}), child: const Text('Next')),
        ],
      ),
    );
  }
}

class _PersonalInfoStep extends StatelessWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  const _PersonalInfoStep({required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    // DOB, Gender picker
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Personal Info', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          // DOB picker, Gender toggle
          Text('Date of Birth & Gender'),
        ],
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  const _LocationStep({required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Where are you from?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Hometown / Region'),
        ],
      ),
    );
  }
}

class _ChurchIntentStep extends StatelessWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  const _ChurchIntentStep({required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Your Community', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Church/Denomination, Languages, Relationship Intent'),
        ],
      ),
    );
  }
}

