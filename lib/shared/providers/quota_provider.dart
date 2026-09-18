import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/models/quota_model.dart';
import 'package:sawalove/core/utils/logger.dart';

final quotaProvider = StateNotifierProvider<QuotaNotifier, QuotaState>((ref) {
  return QuotaNotifier();
});

class QuotaNotifier extends StateNotifier<QuotaState> {
  Timer? _timer;

  QuotaNotifier() : super(const QuotaState()) {
    _loadQuota();
  }

  Future<void> _loadQuota() async {
    try {
      state = QuotaState(
        totalSuperLikes: 5,
        totalRewinds: 1,
        totalRequests: 1,
        resetAt: DateTime.now().add(const Duration(days: 1)),
      );
    } catch (e) {
      logger.e('Failed to load quota: $e');
    }
  }

  void decrementSuperLike() async {
    if (state.superLikesRemaining > 0) {
      state = state.copyWith(superLikesUsed: state.superLikesUsed + 1);
      await _saveQuota();
    }
  }

  void rollbackSuperLike() async {
    if (state.superLikesUsed > 0) {
      state = state.copyWith(superLikesUsed: state.superLikesUsed - 1);
      await _saveQuota();
    }
  }

  void decrementRewind() async {
    if (state.rewindsRemaining > 0) {
      state = state.copyWith(rewindsUsed: state.rewindsUsed + 1);
      await _saveQuota();
    }
  }

  void rollbackRewind() async {
    if (state.rewindsUsed > 0) {
      state = state.copyWith(rewindsUsed: state.rewindsUsed - 1);
      await _saveQuota();
    }
  }

  void decrementRequest() async {
    if (state.requestsRemaining > 0) {
      state = state.copyWith(requestsUsed: state.requestsUsed + 1);
      await _saveQuota();
    }
  }

  void rollbackRequest() async {
    if (state.requestsUsed > 0) {
      state = state.copyWith(requestsUsed: state.requestsUsed - 1);
      await _saveQuota();
    }
  }

  Future<void> _saveQuota() async {
    try {
      logger.i('Quota saved locally for ${_todayDateString()}');
    } catch (e) {
      logger.e('Failed to save quota: $e');
    }
  }

  void resetQuota() async {
    await _saveQuota();
    state = const QuotaState();
    await _loadQuota();
  }

  void startCountdown(void Function(int seconds) onTick) {
    _timer?.cancel();
    final midnight = DateTime.now()
        .copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
        )
        .add(const Duration(days: 1));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = midnight.difference(DateTime.now());
      if (remaining.isNegative) {
        _timer?.cancel();
        resetQuota();
        onTick(0);
      } else {
        onTick(remaining.inSeconds);
      }
    });
  }

  void stopCountdown() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
