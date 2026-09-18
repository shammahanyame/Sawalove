import 'package:flutter/foundation.dart';

@immutable
class QuotaState {
  final int superLikesUsed;
  final int totalSuperLikes;
  final int rewindsUsed;
  final int totalRewinds;
  final int requestsUsed;
  final int totalRequests;
  final DateTime? resetAt;
  final bool isPremium;

  const QuotaState({
    this.superLikesUsed = 0,
    this.totalSuperLikes = 5,
    this.rewindsUsed = 0,
    this.totalRewinds = 3,
    this.requestsUsed = 0,
    this.totalRequests = 1,
    this.resetAt,
    this.isPremium = false,
  });

  int get superLikesRemaining => isPremium ? 999 : (totalSuperLikes - superLikesUsed).clamp(0, totalSuperLikes);
  int get rewindsRemaining => isPremium ? 999 : (totalRewinds - rewindsUsed).clamp(0, totalRewinds);
  int get requestsRemaining => isPremium ? totalRequests : (totalRequests - requestsUsed).clamp(0, totalRequests);

  QuotaState copyWith({
    int? superLikesUsed,
    int? totalSuperLikes,
    int? rewindsUsed,
    int? totalRewinds,
    int? requestsUsed,
    int? totalRequests,
    DateTime? resetAt,
    bool? isPremium,
  }) {
    return QuotaState(
      superLikesUsed: superLikesUsed ?? this.superLikesUsed,
      totalSuperLikes: totalSuperLikes ?? this.totalSuperLikes,
      rewindsUsed: rewindsUsed ?? this.rewindsUsed,
      totalRewinds: totalRewinds ?? this.totalRewinds,
      requestsUsed: requestsUsed ?? this.requestsUsed,
      totalRequests: totalRequests ?? this.totalRequests,
      resetAt: resetAt ?? this.resetAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotaState &&
          runtimeType == other.runtimeType &&
          superLikesUsed == other.superLikesUsed &&
          totalSuperLikes == other.totalSuperLikes &&
          rewindsUsed == other.rewindsUsed &&
          totalRewinds == other.totalRewinds &&
          requestsUsed == other.requestsUsed &&
          totalRequests == other.totalRequests &&
          resetAt == other.resetAt &&
          isPremium == other.isPremium;

  @override
  int get hashCode =>
      superLikesUsed.hashCode ^
      totalSuperLikes.hashCode ^
      rewindsUsed.hashCode ^
      totalRewinds.hashCode ^
      requestsUsed.hashCode ^
      totalRequests.hashCode ^
      resetAt.hashCode ^
      isPremium.hashCode;
}

