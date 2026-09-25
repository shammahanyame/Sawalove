import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/core/config/feature_flags.dart';
import 'package:sawalove/core/utils/logger.dart';
import 'package:sawalove/features/discovery/widgets/filter_sheet.dart';
import 'package:sawalove/shared/providers/filter_provider.dart';
import 'package:sawalove/shared/providers/discovery_provider.dart';
import 'package:sawalove/shared/providers/inbox_provider.dart';
import 'package:sawalove/shared/providers/peer_profile_provider.dart';
import 'package:sawalove/shared/providers/swipe_history_provider.dart';
import 'package:sawalove/shared/services/backend_service.dart';
import 'package:sawalove/shared/models/swipe_record.dart';
import 'package:sawalove/shared/widgets/swipe_card.dart';
import 'package:sawalove/shared/widgets/pressable_scale.dart';
import 'package:sawalove/features/discovery/controllers/super_like_controller.dart';
import 'package:sawalove/features/discovery/controllers/rewind_controller.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  Future<void> _onSwipe(String type, Map<String, dynamic> profile) async {
    final targetUid =
        (profile['uid'] ?? profile['id'] ?? '').toString();

    if (targetUid.isNotEmpty) {
      ref.read(swipeHistoryProvider.notifier).recordSwipe(
            SwipeRecord(
              targetUid: targetUid,
              type: type,
              profile: profile,
              timestamp: DateTime.now(),
            ),
          );
      // If this profile had been restored by a rewind, it is swiped again —
      // drop the local snapshot so it cannot appear twice.
      ref.read(rewoundProfilesProvider.notifier).state = [
        for (final p in ref.read(rewoundProfilesProvider))
          if ((p['uid'] ?? p['id'] ?? '').toString() != targetUid) p,
      ];
    }

    HapticFeedback.lightImpact();

    // Persist the swipe server-side. A mutual like navigates to the match
    // screen; failures are silent for 'nope' and logged for likes (the local
    // deck already advanced, so the UX is not blocked).
    if (targetUid.isEmpty || targetUid.startsWith('demo-')) return;
    final action = switch (type) {
      'like' => 'like',
      'super_like' => 'super_like',
      _ => 'nope',
    };
    try {
      final result = await ref
          .read(backendServiceProvider)
          .sendSwipe(targetUserId: targetUid, action: action);
      if (result.matched && mounted) {
        context.push('/match/${result.matchId}');
      }
    } catch (e) {
      logger.w('Swipe sync failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(discoveryProfilesProvider);
    final filterState = ref.watch(filterProvider);
    final history = ref.watch(swipeHistoryProvider);
    final rewound = ref.watch(rewoundProfilesProvider);
    final myUid = ref.watch(currentUserProvider)?.uid;
    final myProfile = myUid == null
        ? null
        : ref.watch(peerProfileProvider(myUid)).valueOrNull;

    final raw = profilesAsync.value ?? const <Map<String, dynamic>>[];
    final swipedUids = {for (final r in history.records) r.targetUid};

    // Deck = server profiles + rewind snapshots, minus myself, minus
    // anything I already swiped, minus what the active filters reject.
    final seen = <String>{};
    final deck = <Map<String, dynamic>>[];
    for (final profile in [...rewound, ...raw]) {
      if (!_keepInDeck(profile, myUid, swipedUids, filterState, myProfile)) {
        continue;
      }
      final uid = _uidOf(profile);
      if (uid.isNotEmpty && !seen.add(uid)) {
        continue; // duplicate (rewind snapshot still in the server list)
      }
      deck.add(profile);
    }

    return Scaffold(
      backgroundColor: SawaLoveTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.favorite, color: SawaLoveTheme.primary, size: 28),
            SizedBox(width: 8),
            Text(
              'SawaLove',
              style: TextStyle(
                color: SawaLoveTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune, color: SawaLoveTheme.onSurface),
                if (filterState.hasActiveFilters)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: SawaLoveTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => showFilterSheet(context, ref),
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: SawaLoveTheme.onSurface),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: profilesAsync.when(
        data: (_) {
          if (deck.isEmpty) {
            return _EmptyState();
          }
          return _SwipeStack(
            deck: deck,
            onSwipe: _onSwipe,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: SawaLoveTheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('Could not load profiles',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Check your connection and try again.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SawaLoveTheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(discoveryProfilesProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SawaLoveTheme.primary,
                  foregroundColor: SawaLoveTheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Deck composition ────────────────────────────────────────────────────

  static String _uidOf(Map<String, dynamic> profile) =>
      (profile['uid'] ?? profile['id'] ?? '').toString();

  static bool _keepInDeck(
    Map<String, dynamic> profile,
    String? myUid,
    Set<String> swipedUids,
    FilterState filters,
    Map<String, dynamic>? me,
  ) {
    final uid = _uidOf(profile);
    // Never show myself (the server excludes this too; belt and braces).
    if (myUid != null && uid == myUid) return false;
    // Never re-show someone I already swiped.
    if (uid.isNotEmpty && swipedUids.contains(uid)) return false;
    return _passesFilters(profile, filters, me);
  }

  /// Client-side filter application. The server has no filter API, so the
  /// sheet's filters are evaluated here against the fields the API exposes.
  /// Filters with no corresponding data (gender, online-now, lifestyle) are
  /// not evaluated — showing them as active while ignoring them would be
  /// dishonest; see PLAY_STORE_CHECKLIST known limitations.
  static bool _passesFilters(
    Map<String, dynamic> profile,
    FilterState f,
    Map<String, dynamic>? me,
  ) {
    // Age (only enforced once moved away from the defaults).
    if (f.ageMin != 22 || f.ageMax != 35) {
      final age = profile['age'];
      if (age is! int || age < f.ageMin || age > f.ageMax) return false;
    }

    // Has profile photo (default on — stated in the filter sheet).
    final photo = (profile['photo'] ?? '').toString();
    if (f.withPhoto && photo.isEmpty) return false;

    // Faith → preferences.religion (denomination or broad faith).
    if (f.faiths.isNotEmpty && !f.faiths.contains('any_faith')) {
      final prefs = profile['preferences'];
      final dynamic religionRaw = prefs is Map ? prefs['religion'] : null;
      final religion = (religionRaw ?? '').toString().toLowerCase();
      if (!_faithMatches(f.faiths, religion)) return false;
    }

    // Looking for → intent/goal free text.
    if (f.intents.isNotEmpty) {
      final intent =
          '${profile['intent'] ?? ''} ${profile['goal'] ?? ''}'.toLowerCase();
      if (!_intentMatches(f.intents, intent)) return false;
    }

    // Region → city/location/village.
    if (f.regions.isNotEmpty) {
      final place =
          '${profile['city'] ?? ''} ${profile['location'] ?? ''} ${profile['village'] ?? ''}';
      final normalized = _normalize(place);
      if (!f.regions.any((region) => normalized.contains(_normalize(region)))) {
        return false;
      }
    }

    // Distance → straight-line km, but only when BOTH profiles have real
    // coordinates (0,0 is the server default and means "not set").
    if (f.distanceKm < 500 && me != null) {
      final myLat = (me['lat'] as num?)?.toDouble() ?? 0;
      final myLng = (me['lng'] as num?)?.toDouble() ?? 0;
      final theirLat = (profile['lat'] as num?)?.toDouble() ?? 0;
      final theirLng = (profile['lng'] as num?)?.toDouble() ?? 0;
      final haveCoords = myLat != 0 &&
          myLng != 0 &&
          theirLat != 0 &&
          theirLng != 0;
      if (haveCoords &&
          _haversineKm(myLat, myLng, theirLat, theirLng) > f.distanceKm) {
        return false;
      }
    }

    return true;
  }

  static bool _faithMatches(Set<String> selected, String religion) {
    if (religion.isEmpty) return selected.contains('none');
    const christian = [
      'christian',
      'catholic',
      'protestant',
      'pentecostal',
      'baptist',
      'presbyterian',
      'methodist',
      'anglican',
      'orthodox',
      'evangelic',
    ];
    const muslim = ['muslim', 'islam'];
    const traditional = ['traditional', 'animist'];
    if (selected.contains('none') &&
        (religion == 'none' || religion == 'no religion')) {
      return true;
    }
    if (selected.contains('christian') &&
        christian.any(religion.contains)) {
      return true;
    }
    if (selected.contains('muslim') && muslim.any(religion.contains)) {
      return true;
    }
    if (selected.contains('traditional') &&
        traditional.any(religion.contains)) {
      return true;
    }
    return false;
  }

  static bool _intentMatches(Set<String> selected, String intent) {
    bool has(String needle) => intent.contains(needle);
    if (selected.contains('serious') && has('serious')) return true;
    if (selected.contains('marriage') && has('marriage')) return true;
    if (selected.contains('friendship') && has('friend')) return true;
    if (selected.contains('casual') &&
        (has('casual') || has('dating') || has('chatting'))) {
      return true;
    }
    if (selected.contains('networking') && has('network')) return true;
    return false;
  }

  static final _accentPattern = RegExp(r'[àáâãäåèéêëìíîïòóôõöùúûüýÿçœ]');
  static const _accentMap = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y', 'ç': 'c', 'œ': 'oe',
  };

  /// Lowercases and strips accents so 'Yaoundé' matches 'Yaounde'.
  static String _normalize(String value) {
    final lower = value.toLowerCase();
    return lower.replaceAllMapped(
      _accentPattern,
      (match) => _accentMap[match.group(0) ?? ''] ?? match.group(0) ?? '',
    );
  }

  static double _haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    double toRad(double deg) => deg * pi / 180;
    final dLat = toRad(lat2 - lat1);
    final dLng = toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRad(lat1)) * cos(toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}

class _SwipeStack extends ConsumerWidget {
  final List<Map<String, dynamic>> deck;
  final void Function(String, Map<String, dynamic>) onSwipe;

  const _SwipeStack({required this.deck, required this.onSwipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = deck.first;
    final uid = (profile['uid'] ?? profile['id'] ?? '').toString();

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            // The deck is a filtered list: swiping removes the top entry and
            // the next card fades/sides in — no page-index bookkeeping.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: SwipeCard(
                key: ValueKey(uid.isEmpty ? deck.length : uid),
                uid: uid.isEmpty ? 'demo-0' : uid,
                imageUrl: profile['photo'] ??
                    profile['avatar_url'] ??
                    'https://picsum.photos/800/1200',
                name: profile['name'] ?? 'Unknown',
                // null age = unknown; never fabricate one.
                age: profile['age'] is int ? profile['age'] as int : null,
                location: profile['location'] ?? profile['city'] ?? 'Cameroon',
                village: profile['village'] ?? 'Cameroon',
                goal: profile['goal'] ?? profile['intent'] ?? 'Connection',
                bio: profile['bio'] ?? 'New to SawaLove.',
                isVerified: profile['verified'] == true,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _SwipeControls(
            profile: profile,
            onSwipe: onSwipe,
          ),
        ),
      ],
    );
  }
}

class _SwipeControls extends ConsumerWidget {
  final Map<String, dynamic> profile;
  final void Function(String, Map<String, dynamic>) onSwipe;

  const _SwipeControls({required this.profile, required this.onSwipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = (profile['uid'] ?? profile['id'] ?? '').toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Rewind
        _ActionButton(
          icon: Icons.refresh,
          color: SawaLoveTheme.onSurfaceVariant, // neutral: not an accent action
          size: 48,
          onTap: () => RewindController.initiate(context, ref: ref),
          tooltip: 'Undo',
        ),
        // Nope
        _ActionButton(
          icon: Icons.close,
          color: SawaLoveTheme.onSurface, // neutral: pass is a dismissive action
          size: 64,
          onTap: () => onSwipe('nope', profile),
          tooltip: 'Pass',
        ),
        // Super Like (feature not wired to backend yet; hidden in release)
        if (kShowSuperLike)
          _ActionButton(
            icon: Icons.star,
            color: SawaLoveTheme.secondary,
            size: 48,
            onTap: () => SuperLikeController.initiate(
              context,
              uid,
              profile,
              ref: ref,
            ),
            tooltip: 'Super Like',
          ),
        // Like
        _ActionButton(
          icon: Icons.favorite,
          color: SawaLoveTheme.primary,
          size: 64,
          onTap: () => onSwipe('like', profile),
          tooltip: 'Like',
        ),
        // Boost
        _ActionButton(
          icon: Icons.bolt,
          color: SawaLoveTheme.onSurfaceVariant, // neutral: not an accent action
          size: 48,
          onTap: () => context.push('/premium/boost'),
          tooltip: 'Boost',
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: size * 0.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: SawaLoveTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off, size: 60, color: SawaLoveTheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No more profiles nearby',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Try widening your filters or check back later.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: SawaLoveTheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/filters'),
              icon: const Icon(Icons.tune),
              label: const Text('Widen Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SawaLoveTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
