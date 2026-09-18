import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PremiumCheckoutScreen extends StatelessWidget {
  const PremiumCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiers = <Map<String, dynamic>>[
      {'name': 'Basic', 'price': '2,000 FCFA/mo', 'features': ['Unlimited likes', 'See who liked you']},
      {'name': 'Premium', 'price': '5,000 FCFA/mo', 'features': ['All Basic + Boosts', 'Incognito mode']},
      {'name': 'Elite', 'price': '10,000 FCFA/mo', 'features': ['All Premium + Priority', 'Video calls']},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Go Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hero Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.pink.shade400]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 80),
            ),
            const SizedBox(height: 32),
            const Text(
              'Unlock Premium Features',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Find love faster with premium'),
            const SizedBox(height: 48),
            // Tiers
            Expanded(
              child: ListView.builder(
                itemCount: tiers.length,
                itemBuilder: (context, index) {
                  final tier = tiers[index];
                  return Card(
                    child: ListTile(
                      title: Text(tier['name']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tier['features']!.map<Widget>((feature) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 16),
                              const SizedBox(width: 8),
                              Text(feature),
                            ],
                          ),
                        )).toList(),
                      ),
                      trailing: Text(tier['price']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () => _payWithMobileMoney(context, tier['name']!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _payWithMobileMoney(BuildContext context, String tier) {
    // Stub MTN/Orange Mobile Money
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment flow for $tier - Integrate MTN MoMo')),
    );
    context.go('/premium/success');
  }
}

