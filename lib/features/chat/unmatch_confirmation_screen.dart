import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';

class UnmatchConfirmationScreen extends StatefulWidget {
  const UnmatchConfirmationScreen({super.key});

  @override
  State<UnmatchConfirmationScreen> createState() => _UnmatchConfirmationScreenState();
}

class _UnmatchConfirmationScreenState extends State<UnmatchConfirmationScreen> {
  String? _selectedReason;

  final List<String> _reasons = [
    'No longer interested',
    'Different values',
    'Not looking for the same thing',
    'Too far away',
    'Better matches',
    'Safety concern',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SawaLoveTheme.surface,
      appBar: AppBar(
        title: const Text('Unmatch'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unmatching is permanent',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'This will delete your chats and matches.',
                              style: TextStyle(
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Why are you unmatching?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    ..._reasons.map(
                      (reason) {
                        final selected = _selectedReason == reason;
                        return ListTile(
                          title: Text(reason),
                          leading: Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: selected
                                ? SawaLoveTheme.primary
                                : SawaLoveTheme.onSurfaceVariant,
                          ),
                          onTap: () => setState(() => _selectedReason = reason),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: SawaLoveTheme.outlineVariant),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedReason == null ? null : () {
                        // Report unmatch reason to analytics
                        context.pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                      ),
                      child: const Text('Unmatch', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

