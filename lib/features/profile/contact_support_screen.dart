import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isPremium = false;
  final _ticketController = TextEditingController();
  String? _selectedSubject;

  final List<String> _subjects = [
    'Billing Issue',
    'Technical Problem',
    'Account Ban',
    'Report Bug',
    'Other',
  ];

  final List<Map<String, String>> _tickets = [
    {'id': '1', 'subject': 'Payment failed', 'status': 'Open', 'date': '2 days ago'},
    {'id': '2', 'subject': 'Ban appeal', 'status': 'Resolved', 'date': '1 week ago'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ticketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: SawaLoveTheme.primary,
          unselectedLabelColor: SawaLoveTheme.onSurfaceVariant,
          indicatorColor: SawaLoveTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.contact_mail), text: 'Tickets'),
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTicketsTab(),
            _buildChatTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_tickets.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  final ticket = _tickets[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ticket['status'] == 'Open'
                            ? SawaLoveTheme.warning.withValues(alpha: 0.2)
                            : SawaLoveTheme.success.withValues(alpha: 0.2),
                        child: Icon(
                          ticket['status'] == 'Open'
                              ? Icons.pending
                              : Icons.check_circle,
                          color: ticket['status'] == 'Open'
                            ? SawaLoveTheme.warning
                            : SawaLoveTheme.success,
                        ),
                      ),
                      title: Text(ticket['subject']!,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(ticket['date']!),
                      trailing: Chip(
                        label: Text(
                          ticket['status']!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: ticket['status'] == 'Open'
                            ? SawaLoveTheme.warning
                            : SawaLoveTheme.success,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  );
                },
              ),
            ),
          // New ticket form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Ticket',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubject,
                    hint: const Text('Select subject'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    items: _subjects
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSubject = v),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ticketController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe your issue...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Screenshot'),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Ticket submitted! Response within 24h.')),
                            );
                            _ticketController.clear();
                            setState(() => _selectedSubject = null);
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isPremium
                  ? SawaLoveTheme.success.withValues(alpha: 0.1)
                  : SawaLoveTheme.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _isPremium ? Icons.chat : Icons.lock,
                  color: _isPremium ? SawaLoveTheme.success : SawaLoveTheme.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_isPremium
                      ? 'Live chat active (Premium)'
                      : 'Upgrade to Premium for live chat'),
                ),
                if (!_isPremium)
                  TextButton(
                    onPressed: () => context.go('/premium'),
                    child: const Text('Upgrade'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isPremium
                ? ListView(
                    children: [
                      _buildChatBubble('Hi! How can we help you today?', false),
                      _buildChatBubble('My payment failed.', true),
                      _buildChatBubble(
                          'I\'m checking your payment history now...', false),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email_outlined,
                            size: 80, color: SawaLoveTheme.outlineVariant),
                        const SizedBox(height: 24),
                        Text(
                          'Email Support',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'support@sawalove.cm',
                          style: TextStyle(
                              fontSize: 18, color: SawaLoveTheme.primary),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Response within 24 hours',
                          style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
          ),
          if (_isPremium)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? SawaLoveTheme.primary : SawaLoveTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
              color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
