import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/models/photo_slot.dart';
import 'package:sawalove/shared/providers/quota_provider.dart';

class PeerProfileScreen extends StatelessWidget {
  final String uid;
  const PeerProfileScreen({super.key, required this.uid});

  static const _demoPhotos = [
    PhotoSlot(
      url: 'https://via.placeholder.com/800x1200',
      caption: 'Profile photo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => context.push(
                      '/profile/photos',
                      extra: {
                        'profileUid': uid,
                        'photos': _demoPhotos,
                        'name': 'Amaka',
                        'initialIndex': 0,
                        'age': 24,
                        'city': 'Yaounde',
                        'badges': ['Verified'],
                      },
                    ),
                    child: Image.network(
                      _demoPhotos.first.url!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(radius: 30),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amaka, 24',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                'Yaounde - Verified',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: SawaLoveTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: SawaLoveTheme.success,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(color: SawaLoveTheme.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About Amaka',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loves art, music, and exploring Cameroon. Looking for serious relationship.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const _InfoRow(
                    icon: Icons.location_city,
                    label: 'Village: Batoufam',
                  ),
                  const _InfoRow(icon: Icons.church, label: 'Church: Catholic'),
                  const _InfoRow(
                    icon: Icons.language,
                    label: 'Languages: English, French',
                  ),
                  const _InfoRow(
                    icon: Icons.favorite,
                    label: 'Intent: Serious Relationship',
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final quota = ref.watch(quotaProvider);
                final requestsRemaining = quota.requestsRemaining;
                final isPremium = quota.isPremium;
                final canMessage = requestsRemaining > 0 && isPremium;

                return Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Like'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: canMessage
                              ? () => context.go('/request/compose/$uid')
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Upgrade to Premium to message anyone',
                                      ),
                                    ),
                                  );
                                },
                          icon: Icon(canMessage ? Icons.chat : Icons.lock),
                          label: Text(canMessage ? 'Message' : 'Premium'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canMessage
                                ? SawaLoveTheme.primary
                                : SawaLoveTheme.onSurfaceVariant,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
