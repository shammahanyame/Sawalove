import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportUserScreen extends StatefulWidget {
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
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  String? _selectedReason;

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
                onPressed: _selectedReason == null
                    ? null
                    : () => _submitReport(context),
                child: const Text('Submit Report'),
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

  void _submitReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted')),
    );
    context.pop();
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
