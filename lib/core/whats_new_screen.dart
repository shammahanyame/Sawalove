import 'package:flutter/material.dart';


class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: const Text('What\'s New', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Version header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'v2.1.0',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'December 2024',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // New features
                  _buildSection(
                    context,
                    title: '✨ New Features',
                    items: const [
                      '• Notification Center (Likes, Matches, Messages)',
                      '• Moderation Appeal system',
                      '• Offline mode with cached content',
                      '• Force update handling',
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Improvements
                  _buildSection(
                    context,
                    title: '🚀 Improvements',
                    items: const [
                      '• Better moderation AI',
                      '• Faster matching',
                      '• Enhanced privacy controls',
                      '• Cultural matching refined',
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bug fixes
                  _buildSection(
                    context,
                    title: '🐛 Bug Fixes',
                    items: const [
                      '• Fixed chat crashes',
                      '• Location permissions fixed',
                      '• Premium payment flow',
                      '• Dark mode toggle',
                    ],
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text('Got it!', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<String> items}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

