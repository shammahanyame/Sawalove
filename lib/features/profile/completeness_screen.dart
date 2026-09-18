import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/providers/completeness_provider.dart';
import 'package:sawalove/shared/providers/user_provider.dart';
import 'widgets/progress_ring_painter.dart';

class ProfileCompletenessScreen extends ConsumerWidget {
  const ProfileCompletenessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final completenessState = ref.watch(completenessProvider);

    return Scaffold(
      backgroundColor: SawaLoveTheme.surface,
      appBar: AppBar(
        title: const Text('Profile Completeness'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: SawaLoveTheme.onSurface,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user data'));
          }
          // Compute completeness from user data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(completenessProvider.notifier).computeFromUser({'uid': user.uid});
          });
          return _buildContent(context, ref, completenessState);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, CompletenessState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero ring section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SawaLoveTheme.primary.withValues(alpha: 0.05),
                  SawaLoveTheme.primaryContainer.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: state.percentage / 100),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size.square(140),
                            painter: ProgressRingPainter(
                              progress: value,
                              strokeColor: state.percentage >= 100
                                  ? const Color(0xFF1D9E75)
                                  : SawaLoveTheme.primary,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(value * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: SawaLoveTheme.onSurface,
                                ),
                              ),
                              Text(
                                state.percentage >= 100 ? 'Complete!' : 'done',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: SawaLoveTheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCard('${state.points}/100', 'points'),
                    _statCard(
                      '${state.tasks.where((t) => !t.complete).length}',
                      'remaining',
                    ),
                    if (state.visibilityBoost != null)
                      _statCard(state.visibilityBoost!, 'visibility'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Tasks
          Text(
            'Complete your profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...state.tasks.map((task) => _taskCard(context, task)),

          const SizedBox(height: 32),

          // Milestones
          Text(
            'Milestone Rewards',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.milestones.length,
              itemBuilder: (context, index) {
                final milestone = state.milestones[index];
                final isUnlocked = state.percentage >= milestone.threshold;
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _milestoneCard(context, milestone, isUnlocked),
                );
              },
            ),
          ),

          // Reward banners
          ...state.milestones
              .where((m) => m.unlocked && !m.claimed)
              .map((milestone) => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _rewardBanner(context, ref, milestone),
                  )),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: SawaLoveTheme.onSurface,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: SawaLoveTheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _taskCard(BuildContext context, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(task.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: task.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.check_circle_outline, color: task.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      task.description,
                      style: const TextStyle(color: SawaLoveTheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
              task.complete
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Color(0xFF1D9E75)),
                          const SizedBox(width: 4),
                          Text(
                            '+${task.points}',
                            style: const TextStyle(
                              color: Color(0xFF1D9E75),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: task.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+${task.points} pts',
                        style: TextStyle(
                          color: task.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _milestoneCard(BuildContext context, Milestone milestone, bool isUnlocked) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnlocked
              ? [milestone.color.withValues(alpha: 0.12), milestone.color.withValues(alpha: 0.05)]
              : [Colors.grey.shade100, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? milestone.color.withValues(alpha: 0.3) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? Icons.emoji_events : Icons.lock_outline,
            color: isUnlocked ? milestone.color : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            '${milestone.threshold}%',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isUnlocked ? SawaLoveTheme.onSurface : Colors.grey,
            ),
          ),
          Text(
            milestone.title,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? SawaLoveTheme.onSurfaceVariant : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _rewardBanner(BuildContext context, WidgetRef ref, Milestone milestone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [milestone.color.withValues(alpha: 0.15), milestone.color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: milestone.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: milestone.color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: milestone.color),
                ),
                Text(
                  'Tap to claim your reward',
                  style: TextStyle(fontSize: 12, color: milestone.color.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                ref.read(completenessProvider.notifier).claimReward(milestone.threshold),
            style: ElevatedButton.styleFrom(
              backgroundColor: milestone.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Claim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
