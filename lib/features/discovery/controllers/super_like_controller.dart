import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/providers/quota_provider.dart';
import 'package:sawalove/features/discovery/providers/super_like_modal_provider.dart';
import 'package:sawalove/features/discovery/widgets/super_like_modal.dart';
import 'package:sawalove/core/utils/logger.dart';

class SuperLikeController {
  static Future<void> initiate(
    BuildContext context,
    String targetUid,
    Map<String, dynamic> profile, {
    required WidgetRef ref,
  }) async {
    final quota = ref.read(quotaProvider);
    final modalNotifier = ref.read(superLikeModalProvider.notifier);

    if (quota.superLikesRemaining == 0) {
      modalNotifier.setEmpty();
    } else if (quota.superLikesRemaining == 1) {
      modalNotifier.setState(SuperLikeModalState.lastOne);
    } else {
      modalNotifier.setState(SuperLikeModalState.confirm);
    }

    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SuperLikeModal(
        targetUid: targetUid,
        profile: profile,
      ),
    );

    ref.read(quotaProvider.notifier).stopCountdown();
  }

  static Future<void> sendSuperLike(
    BuildContext context,
    String targetUid, {
    required WidgetRef ref,
  }) async {
    // 1. Optimistic local update
    ref.read(quotaProvider.notifier).decrementSuperLike();

    // 2. Haptic feedback
    await HapticFeedback.mediumImpact();

    try {
      // 3. Cloud Function call — transactional, prevents duplicate sends
      // Stub: FirebaseFunctions.instance.httpsCallable('sendSuperLike');
      await Future.delayed(const Duration(milliseconds: 500));

      // 4. Transition modal to sent state
      ref.read(superLikeModalProvider.notifier).setSent();
    } catch (e, stack) {
      logger.e('Super Like send failed', error: e, stackTrace: stack);
      // Rollback on error
      ref.read(quotaProvider.notifier).rollbackSuperLike();
      ref.read(superLikeModalProvider.notifier).setEmpty();
    }
  }
}

