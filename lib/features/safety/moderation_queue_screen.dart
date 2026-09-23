import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../shared/services/backend_service.dart';
import '../../shared/widgets/pressable_scale.dart';

/// Moderation report queue — moderator+ only (the API enforces the role; this
/// screen surfaces the 403 as a friendly "no access" state). FIFO order from
/// the server; every action is audit-logged server-side.
class ModerationQueueScreen extends ConsumerStatefulWidget {
  const ModerationQueueScreen({super.key});

  @override
  ConsumerState<ModerationQueueScreen> createState() =>
      _ModerationQueueScreenState();
}

class _ModerationQueueScreenState extends ConsumerState<ModerationQueueScreen> {
  static const _statusFilters = ['pending', 'upheld', 'dismissed'];

  String _filter = 'pending';
  bool _loading = true;
  bool _forbidden = false;
  String? _error;
  List<Map<String, dynamic>> _reports = const [];
  Set<String> _busyReportIds = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _forbidden = false;
    });
    try {
      final reports = await ref
          .read(backendServiceProvider)
          .fetchModerationReports(status: _filter);
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _loading = false;
      });
    } on BackendAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _forbidden = e.statusCode == 403;
        _error = _forbidden
            ? 'Moderator access is required for this queue.'
            : authErrorMessage(e);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load the queue. Check your connection.';
        _loading = false;
      });
    }
  }

  Future<void> _resolve(Map<String, dynamic> report, String outcome) async {
    final note = await _promptNote(
      title: outcome == 'uphold' ? 'Uphold report' : 'Dismiss report',
      hint: outcome == 'uphold'
          ? 'Optional note for the audit trail'
          : 'Why is this being dismissed?',
    );
    if (note == null) return;

    final id = (report['id'] ?? '').toString();
    setState(() => _busyReportIds = {..._busyReportIds, id});
    try {
      await ref
          .read(backendServiceProvider)
          .resolveReport(reportId: id, outcome: outcome, note: note);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            outcome == 'uphold'
                ? 'Report upheld — account paused for review.'
                : 'Report dismissed.',
          ),
        ),
      );
      await _load();
    } on BackendAuthException catch (e) {
      if (!mounted) return;
      setState(() => _busyReportIds = {..._busyReportIds}..remove(id));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busyReportIds = {..._busyReportIds}..remove(id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed. Try again.')),
      );
    }
  }

  Future<void> _moderateUser(Map<String, dynamic> report) async {
    final userId = (report['reportedUserId'] ?? '').toString();
    final name = (report['reportedName'] ?? 'this user').toString();
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Moderate $name',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            for (final option in const [
              ('pause', 'Pause account', 'Temporarily hides the profile.'),
              ('ban', 'Ban account', 'Permanently blocks sign-in.'),
              ('reinstate', 'Reinstate account', 'Restores full access.'),
            ])
              ListTile(
                leading: Icon(switch (option.$1) {
                  'pause' => Icons.pause_circle_outline,
                  'ban' => Icons.block,
                  _ => Icons.restore,
                }),
                title: Text(option.$2),
                subtitle: Text(option.$3),
                onTap: () => Navigator.pop(context, option.$1),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    final note = await _promptNote(title: 'Add a note (optional)');
    if (note == null) return;

    setState(() => _busyReportIds = {..._busyReportIds, userId});
    try {
      await ref
          .read(backendServiceProvider)
          .setUserStatus(userId: userId, action: action, note: note);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account ${action}d.')),
      );
      if (_filter == 'pending') await _load();
    } on BackendAuthException catch (e) {
      if (!mounted) return;
      setState(() => _busyReportIds = {..._busyReportIds}..remove(userId));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busyReportIds = {..._busyReportIds}..remove(userId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed. Try again.')),
      );
    }
  }

  Future<String?> _promptNote({required String title, String? hint}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: hint ?? 'Note for the audit trail',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report queue'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<String>(
              segments: [
                for (final s in _statusFilters)
                  ButtonSegment(value: s, label: Text(_cap(s))),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) {
                setState(() => _filter = selection.first);
                _load();
              },
            ),
          ),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _forbidden ? Icons.lock_outline : Icons.cloud_off,
                size: 48,
                color: SawaLoveTheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (!_forbidden) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      );
    }
    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 48,
              color: SawaLoveTheme.success,
            ),
            const SizedBox(height: 16),
            Text(
              _filter == 'pending'
                  ? 'Queue is clear. Nice work!'
                  : 'No $_filter reports.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _ReportCard(
            report: report,
            busy: _busyReportIds.contains((report['id'] ?? '').toString()),
            onResolve: () => _resolve(report, 'uphold'),
            onDismiss: () => _resolve(report, 'dismiss'),
            onModerate: () => _moderateUser(report),
          );
        },
      ),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final bool busy;
  final VoidCallback onResolve;
  final VoidCallback onDismiss;
  final VoidCallback onModerate;

  const _ReportCard({
    required this.report,
    required this.busy,
    required this.onResolve,
    required this.onDismiss,
    required this.onModerate,
  });

  @override
  Widget build(BuildContext context) {
    final reason = (report['reason'] ?? '').toString();
    final details = (report['details'] ?? '').toString();
    final name = (report['reportedName'] ?? '').toString();
    final status = (report['status'] ?? 'pending').toString();
    final created = (report['createdAt'] ?? '').toString();
    final isPending = status == 'pending';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.isEmpty ? 'Unknown user' : name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _reasonIcon(reason),
                      size: 16,
                      color: SawaLoveTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reason.replaceAll('_', ' '),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: SawaLoveTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (created.isNotEmpty) ...[
                      const Spacer(),
                      Text(
                        _shortDate(created),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: SawaLoveTheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    details,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SawaLoveTheme.onSurfaceVariant,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: busy ? null : onDismiss,
                          child: const Text('Dismiss'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: SawaLoveTheme.primary,
                          ),
                          onPressed: busy ? null : onResolve,
                          icon: const Icon(Icons.gavel, size: 18),
                          label: const Text('Uphold'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: PressableScale(
                      onTap: busy ? null : onModerate,
                      child: TextButton.icon(
                        onPressed: busy ? null : onModerate,
                        icon: const Icon(Icons.manage_accounts, size: 18),
                        label: const Text('Moderate account…'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _reasonIcon(String reason) => switch (reason) {
        'harassment' => Icons.warning_amber_rounded,
        'fake_profile' => Icons.person_off_outlined,
        'inappropriate_photos' => Icons.image_not_supported_outlined,
        'scam' => Icons.money_off_csred_outlined,
        _ => Icons.flag_outlined,
      };

  static String _shortDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '';
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color, container) = switch (status) {
      'upheld' => (
        Icons.check_circle,
        'Upheld',
        SawaLoveTheme.success,
        SawaLoveTheme.successContainer,
      ),
      'dismissed' => (
        Icons.cancel_outlined,
        'Dismissed',
        SawaLoveTheme.onSurfaceVariant,
        SawaLoveTheme.surfaceContainerHigh,
      ),
      _ => (
        Icons.schedule,
        'Pending',
        SawaLoveTheme.warning,
        SawaLoveTheme.warningContainer,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: container,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
