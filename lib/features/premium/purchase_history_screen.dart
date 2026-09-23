import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final purchases = [
      {'plan': 'Gold', 'amount': 'XAF 5,000', 'date': '2024-12-01', 'expires': '2025-01-01', 'status': 'Active'},
      {'plan': 'Boost', 'amount': 'XAF 1,500', 'date': '2024-11-28', 'expires': '2024-11-30', 'status': 'Expired'},
      {'plan': 'Gold', 'amount': 'XAF 5,000', 'date': '2024-11-01', 'expires': '2024-12-01', 'status': 'Expired'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
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
                'Your Subscriptions',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: purchases.length,
                  itemBuilder: (context, index) {
                    final purchase = purchases[index];
                    final isActive = purchase['status'] == 'Active';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: isActive ? SawaLoveTheme.primaryContainer : SawaLoveTheme.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  purchase['plan']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? Colors.white : null,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? SawaLoveTheme.success : SawaLoveTheme.warning,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    purchase['status']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.receipt_long, size: 16, color: SawaLoveTheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Text('Receipt #${1000 + index}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 16, color: SawaLoveTheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Text(purchase['amount']!),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.payment, size: 16, color: SawaLoveTheme.onSurfaceVariant),
                                SizedBox(width: 8),
                                Text('MTN MoMo'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text('Expires ${purchase['expires']}'),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    minimumSize: const Size(80, 32),
                                  ),
                                  child: const Text('Renew', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('New Purchase'),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

