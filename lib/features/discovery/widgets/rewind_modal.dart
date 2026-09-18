import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/shared/models/quota_model.dart';
import 'package:sawalove/shared/providers/quota_provider.dart';
import 'package:sawalove/features/discovery/providers/rewind_modal_provider.dart';
import 'package:sawalove/features/discovery/controllers/rewind_controller.dart';
import 'package:sawalove/features/discovery/widgets/profile_peek_card.dart';

class RewindModal extends ConsumerStatefulWidget {
  final String targetUid;
  final Map<String, dynamic> profile;
  final String swipeType;

  const RewindModal({
    super.key,
    required this.targetUid,
    required this.profile,
    required this.swipeType,
  });

  @override
  ConsumerState<RewindModal> createState() => _RewindModalState();
}

class _RewindModalState extends ConsumerState<RewindModal>
    with SingleTickerProviderStateMixin {
  String? _countdownLabel;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();

    final modalState = ref.read(rewindModalProvider);
    if (modalState == RewindModalState.empty) {
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
    _animController.dispose();
    ref.read(quotaProvider.notifier).stopCountdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modalState = ref.watch(rewindModalProvider);
    final quota = ref.watch(quotaProvider);
    final name = widget.profile['name'] ?? 'them';

    final isLast = modalState == RewindModalState.last;

    final rewindColor =
        isLast ? const Color(0xFFBA7517) : const Color(0xFFB30065);
    final ringColor =
        isLast ? const Color(0xFFFAEEDA) : const Color(0xFFFFECF1);

    Widget content;
    switch (modalState) {
      case RewindModalState.confirm:
      case RewindModalState.last:
        content = _buildConfirmState(
          context,
          quota: quota,
          isLast: isLast,
          rewindColor: rewindColor,
          ringColor: ringColor,
          name: name,
        );
        break;
      case RewindModalState.empty:
        content = _buildEmptyState(context, name: name, rewindColor: rewindColor);
        break;
      case RewindModalState.premium:
        content = _buildPremiumState(context);
        break;
    }

    return Semantics(
      label: 'Rewind confirmation dialog',
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOutBack,
              )),
              child: FadeTransition(
                opacity: _animController,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
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
          },
        ),
      ),
    );
  }

  Widget _buildConfirmState(
    BuildContext context, {
    required QuotaState quota,
    required bool isLast,
    required Color rewindColor,
    required Color ringColor,
    required String name,
  }) {
    final actionLabel = widget.swipeType == 'like'
        ? 'Undo my Like'
        : widget.swipeType == 'superLike'
            ? 'Undo my Super Like'
            : 'Bring $name back';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ringColor,
            shape: BoxShape.circle,
            border: Border.all(color: rewindColor.withAlpha(77), width: 2),
          ),
          child: Icon(Icons.refresh, size: 48, color: rewindColor),
        ),
        const SizedBox(height: 20),
        Text(
          isLast ? 'Last Rewind — use it wisely' : 'Undo last swipe?',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                color: rewindColor,
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bring $name back to your stack instantly.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        ProfilePeekCard(profile: widget.profile),
        const SizedBox(height: 20),
        _buildRewindDots(quota: quota, isLast: isLast),
        const SizedBox(height: 24),
        Semantics(
          label: '$actionLabel. This will use 1 of your ${quota.rewindsRemaining} remaining Rewinds today.',
          button: true,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => RewindController.executeRewind(
                context,
                ref: ref,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: rewindColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                isLast ? 'Undo — my last Rewind' : actionLabel,
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
            'Keep swiping',
            style: TextStyle(color: Color(0xFF7E4D61)),
          ),
        ),
        if (isLast) ...[
          const SizedBox(height: 8),
          const Text(
            'Premium members get unlimited Rewinds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFBA7517),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String name,
    required Color rewindColor,
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
            Icons.refresh_outlined,
            size: 48,
            color: Color(0xFFD89CB4),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No Rewinds left',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A2134),
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Come back tomorrow or upgrade to Premium for unlimited Rewinds.',
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
              ref.read(rewindModalProvider.notifier).setPremium();
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
      ('Unlimited Rewinds', Icons.refresh),
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
              // Navigate to premium
              // context.push('/premium');
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

  Widget _buildRewindDots({
    required QuotaState quota,
    required bool isLast,
  }) {
    final total = isLast ? 1 : quota.rewindsRemaining.clamp(0, 3);
    final used = isLast ? 0 : quota.rewindsUsed.clamp(0, 3);
    final remaining = total - used;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final bool active = i < remaining;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? const Color(0xFFB30065)
                : const Color(0xFFE0C4D0),
          ),
        );
      }),
    );
  }
}
