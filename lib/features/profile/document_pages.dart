import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Text(
              'Sample privacy policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'This is a placeholder policy. Replace this text with your official privacy policy before publishing to Google Play.',
            ),
            SizedBox(height: 12),
            Text(
              'What we collect: profile information you provide (e.g., name, photos, preferences).',
            ),
            SizedBox(height: 12),
            Text(
              'Location: we use location for matching at city/region level as described in the in-app settings.',
            ),
            SizedBox(height: 12),
            Text(
              'Communications: we store and display chat messages you send.',
            ),
            SizedBox(height: 12),
            Text(
              'Safety: reports and moderation actions are used to protect users.',
            ),
            SizedBox(height: 12),
            Text(
              'Contact: add your support email/URL.',
            ),
          ],
        ),
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Text(
              'Sample terms of service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'This is a placeholder. Replace this text with your official Terms of Service before publishing to Google Play.',
            ),
            SizedBox(height: 12),
            Text(
              'You must follow community guidelines and local laws.',
            ),
            SizedBox(height: 12),
            Text(
              'You are responsible for your account activity.',
            ),
            SizedBox(height: 12),
            Text(
              'We may moderate content and restrict accounts for violations.',
            ),
            SizedBox(height: 12),
            Text(
              'Contact: add your support email/URL.',
            ),
          ],
        ),
      ),
    );
  }
}

