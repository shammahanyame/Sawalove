import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/l10n/app_localizations.dart';
import 'package:sawalove/l10n/app_localizations_en.dart';
import 'package:sawalove/l10n/app_localizations_fr.dart';
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
  /// Locale-independent reason keys. Selection state and the mapping to the
  /// server enum use these — never display labels, which change with the
  /// app language (the old code keyed on English labels, so a French caller
  /// such as the photo viewer silently failed to submit).
  static const String _keyInappropriate = 'inappropriate';
  static const String _keySpam = 'spam';
  static const String _keyHarassment = 'harassment';
  static const String _keyUnderage = 'underage';
  static const String _keyOther = 'other';

  /// Reason key → the server's report reason enum. 'Underage' has no
  /// dedicated server category, so it files as 'other' with the concern
  /// spelled out in details — moderation triage reads the note.
  static const Map<String, String> _apiReasonByKey = {
    _keyInappropriate: 'inappropriate_photos',
    _keySpam: 'fake_profile',
    _keyHarassment: 'harassment',
    _keyUnderage: 'other',
    _keyOther: 'other',
  };

  String? _selectedKey;
  bool _submitting = false;
  bool _initialReasonMapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialReasonMapped) return;
    _initialReasonMapped = true;
    final raw = widget.initialReason?.trim();
    if (_selectedKey == null && raw != null && raw.isNotEmpty) {
      _selectedKey = _keyForLabel(raw);
    }
  }

  /// Maps a display label (localized by the caller, e.g. the photo viewer,
  /// or the legacy hardcoded English) back to a reason key. Both generated
  /// locales are consulted so the mapping survives locale mismatches.
  String? _keyForLabel(String label) {
    final en = AppLocalizationsEn();
    final fr = AppLocalizationsFr();
    final table = <String, String>{
      en.reportReasonInappropriate: _keyInappropriate,
      fr.reportReasonInappropriate: _keyInappropriate,
      'Inappropriate content': _keyInappropriate,
      en.reportReasonSpam: _keySpam,
      fr.reportReasonSpam: _keySpam,
      'Spam or fake profile': _keySpam,
      en.reportReasonHarassment: _keyHarassment,
      fr.reportReasonHarassment: _keyHarassment,
      'Harassment': _keyHarassment,
      en.reportReasonUnderage: _keyUnderage,
      fr.reportReasonUnderage: _keyUnderage,
      'Underage': _keyUnderage,
      en.reportReasonOther: _keyOther,
      fr.reportReasonOther: _keyOther,
      'Other': _keyOther,
    };
    return table[label];
  }

  String? _detailsFor(String key) {
    final parts = <String>[
      if (key == _keyUnderage) 'Underage concern.',
      if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty)
        'Reported from a photo.',
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPhotoReport =
        widget.photoUrl != null && widget.photoUrl!.isNotEmpty;

    final options = <(String, IconData, String)>[
      (_keyInappropriate, Icons.image, l10n.reportReasonInappropriate),
      (_keySpam, Icons.block, l10n.reportReasonSpam),
      (_keyHarassment, Icons.warning, l10n.reportReasonHarassment),
      (_keyUnderage, Icons.child_care, l10n.reportReasonUnderage),
      (_keyOther, Icons.more_horiz, l10n.reportReasonOther),
    ];

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
                  for (final (key, icon, label) in options)
                    _ReportOption(
                      reason: label,
                      icon: icon,
                      selected: _selectedKey == key,
                      onTap: () => _selectReason(key),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedKey == null || _submitting
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

  void _selectReason(String key) {
    setState(() => _selectedKey = key);
  }

  Future<void> _submitReport() async {
    final key = _selectedKey;
    if (key == null || _submitting) return;
    final apiReason = _apiReasonByKey[key];
    if (apiReason == null) {
      // Defensive: keys only ever come from the list above.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a reason first.')),
      );
      return;
    }

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
            details: _detailsFor(key),
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
