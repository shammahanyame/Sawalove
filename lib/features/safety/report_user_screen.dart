import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/backend_service.dart';

class ReportUserScreen extends ConsumerStatefulWidget {
  final String? profileUid;
  final String? initialReason;
  final String? photoUrl;

  const ReportUserScreen({
    super.key,
    this.profileUid,
    this.initialReason,
    this.photoUrl,
  });

  @override
  ConsumerState<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends ConsumerState<ReportUserScreen> {
  String? _selectedReason;
  bool _submitting = false;

  /// UI labels → the server's report reason enum. 'Underage' has no dedicated
  /// server category, so it files as 'other' with the concern spelled out in
  /// details — moderation triage reads the note.
  static const Map<String, String> _reasonApiKeys = {
    'Inappropriate content': 'inappropriate_photos',
    'Spam or fake profile': 'fake_profile',
    'Harassment': 'harassment',
    'Underage': 'other',
    'Other': 'other',
  };

  String? _apiReason(String? label) {
    if (label == null) return null;
    final key = _reasonApiKeys[label];
    if (key == null) return null;
    if (label == 'Underage') return 'other';
    return key;
  }

  String? _detailsFor(String label) {
    final parts = <String>[
      if (label == 'Underage') 'Underage concern.',
      if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty)
        'Reported from a photo.',
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }

  @override
  void initState() {
    super.initState();
    _selectedReason = widget.initialReason;
  }

  @override
  Widget build(BuildContext context) {
    final isPhotoReport =
        widget.photoUrl != null && widget.photoUrl!.isNotEmpty;

    return Scaffold(
      appBar:
          AppBar(title: Text(isPhotoReport ? 'Report Photo' : 'Report User')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPhotoReport
                  ? 'Why are you reporting this photo?'
                  : 'Why are you reporting?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (widget.profileUid != null || isPhotoReport) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (widget.profileUid != null)
                    'Profile: ${widget.profileUid}',
                  if (isPhotoReport) 'Photo attached',
                ].join(' - '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _ReportOption(
                    reason: 'Inappropriate content',
                    icon: Icons.image,
                    selected: _selectedReason == 'Inappropriate content',
                    onTap: () => _selectReason('Inappropriate content'),
                  ),
                  _ReportOption(
                    reason: 'Spam or fake profile',
                    icon: Icons.block,
                    selected: _selectedReason == 'Spam or fake profile',
                    onTap: () => _selectReason('Spam or fake profile'),
                  ),
                  _ReportOption(
                    reason: 'Harassment',
                    icon: Icons.warning,
                    selected: _selectedReason == 'Harassment',
                    onTap: () => _selectReason('Harassment'),
                  ),
                  _ReportOption(
                    reason: 'Underage',
                    icon: Icons.child_care,
                    selected: _selectedReason == 'Underage',
                    onTap: () => _selectReason('Underage'),
                  ),
                  _ReportOption(
                    reason: 'Other',
                    icon: Icons.more_horiz,
                    selected: _selectedReason == 'Other',
                    onTap: () => _selectReason('Other'),
                  ),
                ],
              ),
            ),
              SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedReason == null || _submitting
                    ? null
                    : _submitReport,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectReason(String reason) {
    setState(() => _selectedReason = reason);
  }

  Future<void> _submitReport() async {
    final label = _selectedReason;
    if (label == null || _submitting) return;
    final apiReason = _apiReason(label);
    if (apiReason == null) return;

    // Preview/demo contexts render this screen with no target uid; there is
    // nothing real to file, so keep the legacy confirmation behavior.
    final uid = widget.profileUid?.trim() ?? '';
    if (uid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted')),
      );
      context.pop();
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(backendServiceProvider)
          .submitReport(
            reportedUserId: uid,
            reason: apiReason,
            details: _detailsFor(label),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted. Our moderation team will review it.'),
        ),
      );
      context.pop();
    } on BackendAuthException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(e))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not submit right now. Check your connection and try again.',
          ),
        ),
      );
    }
  }
}

class _ReportOption extends StatelessWidget {
  final String reason;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ReportOption({
    required this.reason,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(reason),
      trailing: Icon(selected ? Icons.check_circle : Icons.chevron_right),
      selected: selected,
      onTap: onTap,
    );
  }
}
