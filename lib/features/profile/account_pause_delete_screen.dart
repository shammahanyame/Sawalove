import 'package:flutter/material.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/services/firebase_service.dart';

class AccountPauseDeleteScreen extends ConsumerWidget {
  const AccountPauseDeleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showPauseDialog(context, ref),
                child: const Card(
                  color: SawaLoveTheme.warningContainer,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.pause_circle_filled,
                            color: SawaLoveTheme.warning, size: 40),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pause Account',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18)),
                              SizedBox(height: 4),
                              Text('Hide from discovery, keep matches/chats',
                                  style: TextStyle(color: SawaLoveTheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _showDeleteDialog(context, ref),
                child: const Card(
                  color: SawaLoveTheme.errorContainer,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever,
                            color: SawaLoveTheme.errorColor, size: 40),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Color(0xFFB71C1C),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('Permanent deletion. 30-day recovery.',
                                  style: TextStyle(color: SawaLoveTheme.errorColor)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: Color(0xFFE57373)),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.download, color: SawaLoveTheme.tertiary),
                  title: const Text('Download Your Data'),
                  subtitle: const Text('Profile, matches, chats (JSON)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _requestDataExport(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pause Account'),
        content: const Text(
            'Your profile will be hidden from discovery. You can resume anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _pauseAccount(context, ref);
            },
            child: const Text('Pause', style: TextStyle(color: SawaLoveTheme.warning)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action is permanent:'),
            Text('- All matches deleted'),
            Text('- Chats cleared'),
            Text('- Profile removed'),
            SizedBox(height: 12),
            Text('30-day recovery available',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _requestDeletion(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: SawaLoveTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _pauseAccount(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseServiceProvider).pauseAccount();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account paused')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pause account: $e')),
      );
    }
  }

  Future<void> _requestDeletion(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseServiceProvider).requestAccountDeletion();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account scheduled for deletion')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not request deletion: $e')),
      );
    }
  }

  Future<void> _requestDataExport(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(firebaseServiceProvider).requestDataExport();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data export request received')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not request data export: $e')),
      );
    }
  }
}
