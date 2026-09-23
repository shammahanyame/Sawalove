import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _faqs = [
    {'q': 'How to verify my phone?', 'a': 'Enter +237 number, get OTP via SMS.'},
    {'q': 'What is Super Like?', 'a': 'Stand out - show immediate interest, premium feature.'},
    {'q': 'How to report a user?', 'a': 'Tap profile → three dots → Report. We review in 24h.'},
    {'q': 'Why no matches?', 'a': 'Complete profile, adjust filters, check location permissions.'},
    {'q': 'Premium benefits?', 'a': 'Unlimited likes, boosts, incognito, priority support.'},
    {'q': 'Is location safe?', 'a': 'City-level only, paused anytime, shared for meetups with consent.'},
    {'q': 'How to delete account?', 'a': 'Profile → Settings → Pause/Delete → Permanent delete removes data in 30 days.'},
    {'q': 'Payment issues?', 'a': 'Contact support via app or email support@sawalove.cm.'},
    {'q': 'Video call not working?', 'a': 'Check permissions, stable WiFi, update app.'},
    {'q': 'How to appeal ban?', 'a': 'Privacy → Moderation Appeals → Submit form.'},
    {'q': 'Languages?', 'a': 'English/Français - toggle in settings.'},
    {'q': 'Cultural matching?', 'a': 'Religion/ethnicity preferences for better Cameroonian/diaspora matches.'},
  ];

  List<Map<String, String>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    return _faqs.where((faq) => 
      faq['q']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      faq['a']!.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_support),
            onPressed: () => context.go('/profile/contact-support'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Search
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search help articles...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${_filteredFaqs.length} results',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredFaqs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: SawaLoveTheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text('No results found', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Text('Clear search'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredFaqs.length,
                      itemBuilder: (context, index) {
                        final faq = _filteredFaqs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: SawaLoveTheme.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.help_outline, color: SawaLoveTheme.primary),
                            ),
                            title: Text(faq['q']!),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(faq['a']!, style: Theme.of(context).textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

