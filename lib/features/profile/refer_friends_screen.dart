import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';

class ReferFriendsScreen extends StatefulWidget {
  const ReferFriendsScreen({super.key});

  @override
  State<ReferFriendsScreen> createState() => _ReferFriendsScreenState();
}

class _ReferFriendsScreenState extends State<ReferFriendsScreen> {
  final String _referralCode = 'SAWA${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase().substring(0, 6)}';
  
  final List<Map<String, String>> _referrals = [
    {'friend': 'Pierre M.', 'status': 'Active', 'reward': '7 days Premium'},
    {'friend': 'Sarah K.', 'status': 'Pending', 'reward': 'Pending'},
    {'friend': 'David B.', 'status': 'Active', 'reward': '3 days Premium'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Friends'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Your referral code
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.card_giftcard, color: SawaLoveTheme.primary, size: 28),
                          SizedBox(width: 12),
                          Text('Your Referral Code', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _referralCode,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _referralCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Code copied!')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Share this code: "Join SawaLove with $_referralCode for free Super Likes!"'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Share buttons
              const Text('Invite your friends:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.message),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // Mock share
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('WhatsApp share: "Join SawaLove with $_referralCode"')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.sms),
                    label: const Text('SMS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('SMS sent with referral code')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Rewards tracker
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 28),
                        SizedBox(width: 12),
                        Text('Rewards (3 active referrals)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _referrals.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final referral = _referrals[index];
                          final statusColor = referral['status'] == 'Active' ? Colors.green : Colors.orange;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withValues(alpha: 0.2),
                                child: Icon(Icons.person, color: statusColor),
                              ),
                              title: Text(referral['friend']!),
                              subtitle: Text('${referral['status']} • ${referral['reward']}'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Reward details: ${referral['reward']}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
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
}

