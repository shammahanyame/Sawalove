import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/providers/discovery_provider.dart';
import 'package:sawalove/shared/providers/quota_provider.dart';
import 'package:sawalove/shared/providers/swipe_history_provider.dart';
import 'package:sawalove/features/discovery/providers/rewind_modal_provider.dart';
import 'package:sawalove/features/discovery/widgets/rewind_modal.dart';

class RewindController {
  static void initiate(
    BuildContext context, {
    required WidgetRef ref,
  }) {
    final quota = ref.read(quotaProvider);
    final lastSwipe = ref.read(swipeHistoryProvider).lastSwipe;

    if (lastSwipe == null) return;

    if (quota.rewindsRemaining == 0) {
      ref.read(rewindModalProvider.notifier).setEmpty();
    } else if (quota.rewindsRemaining == 1) {
      ref.read(rewindModalProvider.notifier).setLast();
    } else {
      ref.read(rewindModalProvider.notifier).setConfirm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RewindModal(
        targetUid: lastSwipe.targetUid,
        profile: lastSwipe.profile,
        swipeType: lastSwipe.type,
      ),
    );
  }

  static Future<void> executeRewind(
    BuildContext context, {
    required WidgetRef ref,
  }) async {
    final lastSwipe = ref.read(swipeHistoryProvider).lastSwipe;
    if (lastSwipe == null) return;

    // 1. Optimistic local state update
    ref.read(swipeHistoryProvider.notifier).popLast();
    ref.read(quotaProvider.notifier).decrementRewind();

    // The server excludes already-swiped users from GET /users, so the
    // rewound profile only returns via this local snapshot. The deck
    // dedupes by uid, so prepending is safe even when the server list
    // still contains the profile.
    final snapshot = lastSwipe.profile;
    if (snapshot.isNotEmpty) {
      final snapshotUid =
          (snapshot['uid'] ?? snapshot['id'] ?? '').toString();
      final restored = ref.read(rewoundProfilesProvider);
      final alreadyRestored = snapshotUid.isNotEmpty &&
          restored.any((p) =>
              (p['uid'] ?? p['id'] ?? '').toString() == snapshotUid);
      if (!alreadyRestored) {
        ref.read(rewoundProfilesProvider.notifier).state = [
          snapshot,
          ...restored,
        ];
      }
    }

    // 2. Haptic
    await HapticFeedback.lightImpact();

    // 3. Dismiss modal
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // 4. Server-side would go here (Firebase Functions)
    // final callable = FirebaseFunctions.instance.httpsCallable('rewindSwipe');
    // await callable.call({'targetUid': lastSwipe.targetUid, 'swipeType': lastSwipe.type});
  }
}
