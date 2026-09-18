import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class RelationshipIntentScreen extends StatefulWidget {
  const RelationshipIntentScreen({super.key});

  @override
  State<RelationshipIntentScreen> createState() => _RelationshipIntentScreenState();
}

class _RelationshipIntentScreenState extends State<RelationshipIntentScreen> {
  String _selectedIntent = '';

  final Map<String, IconData> intents = {
    'Friendship': Icons.people,
    'Dating': Icons.favorite,
    'Marriage': Icons.ring_volume,
    'Networking': Icons.business,
  };

  void _selectIntent(String intent) {
    setState(() => _selectedIntent = intent);
  }

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
                value: 0.4,
                backgroundColor: SawaLoveTheme.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation<Color>(SawaLoveTheme.primary),
              ),
              const SizedBox(height: 48),
              // Hero
              Text(
                'What brings you here?',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your primary goal',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: SawaLoveTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              // Intent cards
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: intents.length,
                  itemBuilder: (context, index) {
                    final intent = intents.keys.elementAt(index);
                    final isSelected = _selectedIntent == intent;
                    return GestureDetector(
                      onTap: () => _selectIntent(intent),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                            ? const LinearGradient(colors: [SawaLoveTheme.primary, SawaLoveTheme.primaryContainer])
                            : const LinearGradient(colors: [SawaLoveTheme.surfaceContainerLowest, Colors.white]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isSelected ? SawaLoveTheme.primary : SawaLoveTheme.onSurface)
                                .withValues(alpha: isSelected ? 0.3 : 0.1),
                              blurRadius: isSelected ? 24 : 12,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                intents[intent],
                                size: 40,
                                color: isSelected ? Colors.white : SawaLoveTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              intent,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : SawaLoveTheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIntent.isNotEmpty
                    ? () => context.go('/onboarding/photos')
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

