import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';

/// Invite friends — copies a real, verifiable invite message to the
/// clipboard.
///
/// The previous version invented a referral code the backend never
/// validates, fake "active referrals", and promised Premium rewards that
/// are never granted — all Play Deceptive Behaviour violations. There is no
/// referral attribution backend yet, so this screen shares an honest invite
/// link and promises nothing it cannot deliver.
class ReferFriendsScreen extends StatefulWidget {
  const ReferFriendsScreen({super.key});

  @override
  State<ReferFriendsScreen> createState() => _ReferFriendsScreenState();
}

class _ReferFriendsScreenState extends State<ReferFriendsScreen> {
  static const String _packageName = 'com.shammah.sawalove';
  static const String _storeUrl =
      'https://play.google.com/store/apps/details?id=$_packageName';

  String get _inviteMessage =>
      'Meet me on SawaLove — dating app for Cameroon! $_storeUrl';

  Future<void> _copyInvite() async {
    await Clipboard.setData(ClipboardData(text: _inviteMessage));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite copied — paste it into WhatsApp or SMS.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Friends'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.card_giftcard,
                              color: SawaLoveTheme.primary, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Invite your friends',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SawaLoveTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _inviteMessage,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy invite'),
                          onPressed: _copyInvite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How it works',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Copy the invite above and send it to a friend. Once they '
                'install SawaLove from the link, you can start matching — '
                'no codes needed.',
                style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
