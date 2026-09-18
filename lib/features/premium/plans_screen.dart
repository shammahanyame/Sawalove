import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
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
                'Unlock Premium',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Meet 10x more people, faster matches.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  children: [
                    // Plans comparison
                    Expanded(
                      child: Column(
                        children: [
                          // Headers
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: SawaLoveTheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(child: Text('Basic')),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [SawaLoveTheme.primaryContainer, SawaLoveTheme.primary],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      children: [
                                        Text('Gold', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        Text('Popular', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: SawaLoveTheme.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(child: Text('Platinum')),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Features
                          Expanded(
                            child: ListView(
                              children: [
                                _featureRow(Icons.all_inclusive, ['Limited', '✅ Unlimited', '✅ Unlimited']),
                                _featureRow(Icons.flash_on, ['No', '✅ Boosts', '✅ Priority Boosts']),
                                _featureRow(Icons.visibility, ['Basic', '✅ Rewinds', '✅ Super Rewinds']),
                                _featureRow(Icons.star, ['No', '✅ 5 Super Likes/week', '✅ Unlimited']),
                                _featureRow(Icons.visibility_off, ['Public', '✅ Ghost Mode', '✅ Ghost + Incognito']),
                                _featureRow(Icons.map, ['50km', '✅ 200km+', '✅ Global']),
                                _featureRow(Icons.support_agent, ['Email', '✅ Priority Support', '✅ 24/7 Support']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price cards
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text('Free', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                  Text('XAF 0 / month', style: TextStyle(color: SawaLoveTheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => context.go('/premium/payment'),
                            child: const Card(
                              elevation: 8,
                              color: SawaLoveTheme.primaryContainer,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text('Gold', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('XAF 5,000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('per month', style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text('Platinum', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  Text('XAF 15,000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SawaLoveTheme.secondary)),
                                  Text('per month', style: TextStyle(color: SawaLoveTheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, List<String> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: SawaLoveTheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Center(child: Text(values[0])),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Center(child: Text(values[1])),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Center(child: Text(values[2])),
          ),
        ],
      ),
    );
  }
}

