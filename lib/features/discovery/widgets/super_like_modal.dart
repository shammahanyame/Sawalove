import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/shared/models/quota_model.dart';
import 'package:sawalove/shared/providers/quota_provider.dart';
import 'package:sawalove/features/discovery/providers/super_like_modal_provider.dart';
import 'package:sawalove/features/discovery/controllers/super_like_controller.dart';
import 'package:sawalove/features/discovery/widgets/profile_peek_card.dart';
import 'package:sawalove/features/discovery/widgets/quota_dots.dart';

class SuperLikeModal extends ConsumerStatefulWidget {
  final String targetUid;
  final Map<String, dynamic> profile;

  const SuperLikeModal({
    super.key,
    required this.targetUid,
    required this.profile,
  });

  @override
  ConsumerState<SuperLikeModal> createState() => _SuperLikeModalState();
}

class _SuperLikeModalState extends ConsumerState<SuperLikeModal> {
  String? _countdownLabel;

  @override
  void initState() {
    super.initState();
    final modalState = ref.read(superLikeModalProvider);
    if (modalState == SuperLikeModalState.sent ||
        modalState == SuperLikeModalState.empty) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    ref.read(quotaProvider.notifier).startCountdown((seconds) {
      if (mounted) {
        setState(() {
          _countdownLabel = _formatDuration(seconds);
        });
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    ref.read(quotaProvider.notifier).stopCountdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modalState = ref.watch(superLikeModalProvider);
    final quota = ref.watch(quotaProvider);
    final name = widget.profile['name'] ?? 'them';

    final isLastOne = modalState == SuperLikeModalState.lastOne;
    final isSent = modalState == SuperLikeModalState.sent;

    final starRingColor =
        isLastOne ? const Color(0xFFFAEEDA) : const Color(0xFFE7C5FF);
    final ctaColor =
        isLastOne ? const Color(0xFFBA7517) : const Color(0xFF8329C8);
    final starFillColor = isSent ? const Color(0xFFE7C5FF) : Colors.white;

    Widget content;
    switch (modalState) {
      case SuperLikeModalState.confirm:
      case SuperLikeModalState.lastOne:
        content = _buildConfirmState(
          context,
          quota: quota,
          isLastOne: isLastOne,
          starRingColor: starRingColor,
          ctaColor: ctaColor,
          name: name,
        );
        break;
      case SuperLikeModalState.sent:
        content = _buildSentState(
          context,
          name: name,
          starFillColor: starFillColor,
        );
        break;
      case SuperLikeModalState.empty:
        content = _buildEmptyState(context, name: name, ctaColor: ctaColor);
        break;
      case SuperLikeModalState.premium:
        content = _buildPremiumState(context);
        break;
    }

    return Semantics(
      label: 'Super Like confirmation dialog',
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmState(
    BuildContext context, {
    required QuotaState quota,
    required bool isLastOne,
    required Color starRingColor,
    required Color ctaColor,
    required String name,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: starRingColor,
            shape: BoxShape.circle,
            border: Border.all(color: ctaColor.withValues(alpha: 0.3), width: 2),
          ),
          child: Icon(Icons.star, size: 48, color: ctaColor),
        ),
        const SizedBox(height: 20),
        Text(
          isLastOne ? 'Use my last Super Like' : 'Send Super Like',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                color: ctaColor,
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stand out! They\'ll see you first and get a notification.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        ProfilePeekCard(profile: widget.profile),
        const SizedBox(height: 20),
        QuotaDots(quota: quota, showPreview: true),
        const SizedBox(height: 24),
        Semantics(
          label:
              'Send Super Like to $name. This will use 1 of your ${quota.superLikesRemaining} remaining Super Likes today.',
          button: true,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => SuperLikeController.sendSuperLike(
                context,
                widget.targetUid,
                ref: ref,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ctaColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                isLastOne ? 'Use my last Super Like' : 'Send Super Like',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Maybe later',
            style: TextStyle(color: Color(0xFF7E4D61)),
          ),
        ),
        if (isLastOne) ...[
          const SizedBox(height: 8),
          Text(
            'Premium members get 15 Super Likes per day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFBA7517).withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSentState(
    BuildContext context, {
    required String name,
    required Color starFillColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: starFillColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star, size: 48, color: Color(0xFF8329C8)),
        ),
        const SizedBox(height: 20),
        Text(
          'Super Like sent!',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8329C8),
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '$name will be notified immediately.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        if (_countdownLabel != null)
          Semantics(
            label:
                'Quota resets in ${_countdownLabel!.split(':')[0]} hours ${_countdownLabel!.split(':')[1]} minutes.',
            liveRegion: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECF1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Resets in $_countdownLabel',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB30065),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8329C8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Keep swiping',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/profile/${widget.targetUid}');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8329C8),
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF8329C8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'View $name\'s profile',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String name,
    required Color ctaColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4F6),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD89CB4), width: 2),
          ),
          child: const Icon(
            Icons.star_outline,
            size: 48,
            color: Color(0xFFD89CB4),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'You\'re out of Super Likes',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A2134),
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Come back tomorrow or upgrade to Premium for 15 per day.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        if (_countdownLabel != null)
          Semantics(
            label:
                'Quota resets in ${_countdownLabel!.split(':')[0]} hours ${_countdownLabel!.split(':')[1]} minutes.',
            liveRegion: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECF1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Resets in $_countdownLabel',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB30065),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(superLikeModalProvider.notifier).setPremium();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8329C8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Get more with Premium',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7E4D61),
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFD89CB4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Dismiss',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumState(BuildContext context) {
    final benefits = [
      ('15 Super Likes per day', Icons.star),
      ('See who liked you', Icons.favorite),
      ('Unlimited swipes', Icons.swipe),
      ('Priority support', Icons.headset_mic),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.workspace_premium,
          size: 64,
          color: Color(0xFF8329C8),
        ),
        const SizedBox(height: 16),
        Text(
          'Go Premium',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8329C8),
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Unlock the full SawaLove experience',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...benefits.map((benefit) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(benefit.$2, color: const Color(0xFF8329C8)),
                const SizedBox(width: 12),
                Text(
                  benefit.$1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFECF1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '4,500 XAF',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB30065),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '/month',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7E4D61),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '4 500 FCFA/mois',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7E4D61),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8329C8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Continue to Premium',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7E4D61),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Continue without Premium',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
