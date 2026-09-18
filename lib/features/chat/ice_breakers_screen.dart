import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class IceBreakersScreen extends StatelessWidget {
  IceBreakersScreen({super.key});

  final List<Map<String, String>> _iceBreakers = [
    {
      'text': 'Love your hometown! How long have you been in Douala?',
      'category': 'Location',
    },
    {
      'text': 'What\'s your favorite Cameroonian dish to cook?',
      'category': 'Culture',
    },
    {
      'text': "What's the best ndolo party you've been to?",
      'category': 'Fun',
    },
    {
      'text': 'Which church song gets you dancing?',
      'category': 'Faith',
    },
    {
      'text': 'What made you smile today?',
      'category': 'Positive',
    },
    {
      'text': 'If you could visit any region in Cameroon, where?',
      'category': 'Adventure',
    },
    {
      'text': 'Favorite Bible verse for relationships?',
      'category': 'Faith',
    },
    {
      'text': 'MTN or Orange? Be honest! 😄',
      'category': 'Fun',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ice Breakers'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: const [
                  TextSpan(text: 'AI suggested openers for '),
                  TextSpan(
                    text: 'Amaka N.',
                    style: TextStyle(color: SawaLoveTheme.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _iceBreakers.length,
                itemBuilder: (context, index) {
                  final breaker = _iceBreakers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      dense: true,
                      title: Text(
                        breaker['text']!,
                        style: const TextStyle(height: 1.4),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          breaker['category']!,
                          style: const TextStyle(
                            color: SawaLoveTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Copy to clipboard + send logic
                          Navigator.pop(context, breaker['text']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SawaLoveTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Send', style: TextStyle(fontSize: 12)),
                      ),
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
}

// Usage: showModalBottomSheet(builder: (_) => IceBreakersScreen())

