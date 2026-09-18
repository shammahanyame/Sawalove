import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModerationAppealScreen extends StatefulWidget {
  const ModerationAppealScreen({super.key});

  @override
  State<ModerationAppealScreen> createState() => _ModerationAppealScreenState();
}

class _ModerationAppealScreenState extends State<ModerationAppealScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  final _explanationController = TextEditingController();
  bool _hasPhoto = false;
  final List<Map<String, String>> _appealStatus = [
    {'id': '1', 'date': '2 days ago', 'type': 'Photo flag', 'status': 'Pending Review'},
    {'id': '2', 'date': '1 week ago', 'type': 'Profile violation', 'status': 'Rejected'},
  ];

  final List<String> _banReasons = [
    'Inappropriate photos',
    'Harassment messages',
    'Fake profile',
    'Spam behavior',
    'Hate speech',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Appeal'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status history
                if (_appealStatus.isNotEmpty) ...[
                  Text(
                    'Previous Appeals (${_appealStatus.length})',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  ..._appealStatus.map((appeal) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(appeal['status']!).withValues(alpha: 0.2),
                        child: Text(appeal['status']![0], style: TextStyle(color: _getStatusColor(appeal['status']!))),
                      ),
                      title: Text('${appeal['type']}'),
                      subtitle: Text(appeal['date']!),
                      trailing: Chip(
                        label: Text(appeal['status']!),
                        backgroundColor: _getStatusColor(appeal['status']!),
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                // New appeal form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.gavel, color: Colors.orange),
                            const SizedBox(width: 12),
                            Text('New Appeal', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Reason dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedReason,
                          decoration: InputDecoration(
                            labelText: 'Reason for ban/flag',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _banReasons.map((reason) => DropdownMenuItem(value: reason, child: Text(reason))).toList(),
                          onChanged: (value) => setState(() => _selectedReason = value),
                          validator: (value) => value == null ? 'Select reason' : null,
                        ),
                        const SizedBox(height: 16),
                        // Explanation
                        TextFormField(
                          controller: _explanationController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Explain why you believe this was a mistake',
                            hintText: 'Provide details, context, or new information...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => (value ?? '').length < 20 ? 'Minimum 20 characters' : null,
                        ),
                        const SizedBox(height: 16),
                        // Photo evidence
                        ListTile(
                          leading: Stack(
                            children: [
                              const Icon(Icons.photo, color: Colors.grey),
                              if (_hasPhoto) const Positioned(right: 0, child: Icon(Icons.check_circle, color: Colors.green, size: 20)),
                            ],
                          ),
                          title: const Text('Add photo evidence'),
                          subtitle: const Text('Screenshot of error or proof'),
                          trailing: IconButton(
                            icon: const Icon(Icons.upload_file),
                            onPressed: () {
                              setState(() => _hasPhoto = true);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo uploaded')));
                            },
                          ),
                          onTap: () {},
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Appeal submitted! Review within 48 hours.')),
                                );
                                _explanationController.clear();
                                setState(() {
                                  _selectedReason = null;
                                  _hasPhoto = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Submit Appeal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'Pending Review' => Colors.orange,
      'Approved' => Colors.green,
      'Rejected' => Colors.red,
      _ => Colors.grey,
    };
  }
}

