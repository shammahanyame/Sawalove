import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/providers/inbox_provider.dart';

class UnmatchConfirmationScreen extends ConsumerStatefulWidget {
  /// The match to end. Passed as a query param by the chat screen; when
  /// null/empty the screen only records the reason (demo/no-op).
  final String? matchId;

  const UnmatchConfirmationScreen({super.key, this.matchId});

  @override
  ConsumerState<UnmatchConfirmationScreen> createState() =>
      _UnmatchConfirmationScreenState();
}

class _UnmatchConfirmationScreenState
    extends ConsumerState<UnmatchConfirmationScreen> {
  String? _selectedReason;
  bool _submitting = false;

  final List<String> _reasons = [
    'No longer interested',
    'Different values',
    'Not looking for the same thing',
    'Too far away',
    'Better matches',
    'Safety concern',
    'Other',
  ];

  /// Ends the match on the server (hides the conversation for me; the other
  /// side keeps their history) and pops `true` so the chat screen can return
  /// to the inbox. On failure the user stays here and can retry.
  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final matchId = widget.matchId;
      if (matchId != null && matchId.isNotEmpty) {
        await ref.read(inboxRepositoryProvider).unmatch(matchId);
      }
      if (!mounted) return;
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not unmatch. Please try again.')),
      );
    }
  }

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
              const Card(
                color: SawaLoveTheme.errorContainer,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: SawaLoveTheme.errorColor, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unmatching is permanent',
                              style: TextStyle(
                                color: SawaLoveTheme.errorColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'This will delete your chats and matches.',
                              style: TextStyle(
                                color: SawaLoveTheme.errorColor,
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
                  const SizedBox(width: 16),                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedReason == null || _submitting
                            ? null
                            : _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SawaLoveTheme.errorColor,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Unmatch',
                                style: TextStyle(color: Colors.white)),
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

