// lib/shared/providers/completeness_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// Profile Completeness state
class CompletenessState {
  final int percentage;
  final int points;
  final List<Task> tasks;
  final List<Milestone> milestones;
  final List<ClaimedReward> claimedRewards;
  final String? visibilityBoost;

  const CompletenessState({
    this.percentage = 0,
    this.points = 0,
    this.tasks = const [],
    this.milestones = const [],
    this.claimedRewards = const [],
    this.visibilityBoost,
  });

  CompletenessState copyWith({
    int? percentage,
    int? points,
    List<Task>? tasks,
    List<Milestone>? milestones,
    List<ClaimedReward>? claimedRewards,
    String? visibilityBoost,
  }) {
    return CompletenessState(
      percentage: percentage ?? this.percentage,
      points: points ?? this.points,
      tasks: tasks ?? this.tasks,
      milestones: milestones ?? this.milestones,
      claimedRewards: claimedRewards ?? this.claimedRewards,
      visibilityBoost: visibilityBoost ?? this.visibilityBoost,
    );
  }
}

/// Individual task
class Task {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool complete;
  final String icon;
  final Color color;
  final String route;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.complete = false,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// Milestone reward
class Milestone {
  final int threshold;
  final String title;
  final String icon;
  final Color color;
  final bool unlocked;
  final bool claimed;

  const Milestone({
    required this.threshold,
    required this.title,
    required this.icon,
    required this.color,
    this.unlocked = false,
    this.claimed = false,
  });
}

/// Claimed reward
class ClaimedReward {
  final String type;
  final DateTime expiresAt;

  const ClaimedReward({
    required this.type,
    required this.expiresAt,
  });
}

/// Completeness Notifier
class CompletenessNotifier extends StateNotifier<CompletenessState> {
  CompletenessNotifier() : super(const CompletenessState());

  void computeFromUser(Map<String, dynamic> userData) {
    int points = 0;
    final tasks = <Task>[];

    final hasPhotos = (userData['photos'] as List?)?.isNotEmpty ?? false;
    points += hasPhotos ? 20 : 0;
    tasks.add(Task(
      id: 'photos',
      title: 'Add photos',
      description: 'Clear face photos get 3x more likes',
      points: 20,
      complete: hasPhotos,
      icon: 'photo_camera',
      color: const Color(0xFFB30065),
      route: '/onboarding/photos',
    ));

    final isPhotoVerified = userData['isPhotoVerified'] == true;
    points += isPhotoVerified ? 20 : 0;
    tasks.add(Task(
      id: 'photo_verification',
      title: 'Photo verification',
      description: 'Get the verified badge',
      points: 20,
      complete: isPhotoVerified,
      icon: 'verified',
      color: const Color(0xFFFFAB00),
      route: '/onboarding/verification',
    ));

    final hasBio = ((userData['bio'] as String?)?.length ?? 0) > 30;
    points += hasBio ? 15 : 0;
    tasks.add(Task(
      id: 'bio',
      title: 'Bio & tagline',
      description: 'Tell your story',
      points: 15,
      complete: hasBio,
      icon: 'edit',
      color: const Color(0xFF8329C8),
      route: '/profile/edit',
    ));

    final phoneVerified = userData['phoneVerified'] == true;
    points += phoneVerified ? 15 : 0;
    tasks.add(Task(
      id: 'phone',
      title: 'Phone verification',
      description: 'Unlock Premium & Super Likes',
      points: 15,
      complete: phoneVerified,
      icon: 'phone',
      color: const Color(0xFFFFAB00),
      route: '/login',
    ));

    final hasIntent = (userData['intents'] as List?)?.isNotEmpty ?? false;
    points += hasIntent ? 10 : 0;
    tasks.add(Task(
      id: 'intent',
      title: 'Relationship intent',
      description: 'Serious, casual, marriage...',
      points: 10,
      complete: hasIntent,
      icon: 'favorite',
      color: const Color(0xFFB30065),
      route: '/onboarding/intent',
    ));

    final hasFaith = userData['religion'] != null;
    points += hasFaith ? 10 : 0;
    tasks.add(Task(
      id: 'faith',
      title: 'Faith',
      description: 'Christian, Muslim, Traditional...',
      points: 10,
      complete: hasFaith,
      icon: 'church',
      color: const Color(0xFF00647C),
      route: '/onboarding/religion',
    ));

    final hasPreferences = userData['preferences'] != null;
    points += hasPreferences ? 10 : 0;
    tasks.add(Task(
      id: 'preferences',
      title: 'Preferences & deal-breakers',
      description: 'Age, distance, smokers...',
      points: 10,
      complete: hasPreferences,
      icon: 'tune',
      color: const Color(0xFFB30065),
      route: '/onboarding/preferences',
    ));

    final hasTribeRegion = userData['tribeRegion'] != null;
    points += hasTribeRegion ? 5 : 0;
    tasks.add(Task(
      id: 'tribe_region',
      title: 'Tribe & region',
      description: 'Bamileke, Douala, Bafoussam...',
      points: 5,
      complete: hasTribeRegion,
      icon: 'public',
      color: const Color(0xFF00647C),
      route: '/onboarding/ethnicity',
    ));

    final percentage = points.clamp(0, 100);
    final visibilityBoost = percentage >= 50
        ? '+$percentage% more visibility'
        : null;

    final milestones = [
      Milestone(
        threshold: 25,
        title: 'Appear in search',
        icon: 'search',
        color: const Color(0xFFB30065),
        unlocked: percentage >= 25,
      ),
      Milestone(
        threshold: 50,
        title: 'Free 30-min Boost',
        icon: 'bolt',
        color: const Color(0xFFFFAB00),
        unlocked: percentage >= 50,
      ),
      Milestone(
        threshold: 75,
        title: '1-week Premium trial',
        icon: 'star',
        color: const Color(0xFFBA7517),
        unlocked: percentage >= 75,
      ),
      Milestone(
        threshold: 100,
        title: 'Daily Super Likes ×7 days',
        icon: 'double_arrow',
        color: const Color(0xFF1D9E75),
        unlocked: percentage >= 100,
      ),
    ];

    state = CompletenessState(
      percentage: percentage,
      points: points,
      tasks: tasks,
      milestones: milestones,
      visibilityBoost: visibilityBoost,
    );
  }

  Future<void> claimReward(int milestonePct) async {
    try {
      final newRewards = [
        ...state.claimedRewards,
        ClaimedReward(
          type: 'milestone_$milestonePct',
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        ),
      ];
      state = state.copyWith(claimedRewards: newRewards);
    } catch (_) {
      // Silently fail – UI shows snackbar separately
    }
  }

  Task? getNextTask() {
    final incomplete = state.tasks.where((t) => !t.complete).toList();
    if (incomplete.isEmpty) return null;
    return incomplete.reduce((a, b) => a.points > b.points ? a : b);
  }
}

final completenessProvider =
    StateNotifierProvider<CompletenessNotifier, CompletenessState>(
        (ref) => CompletenessNotifier());
