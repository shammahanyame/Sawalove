import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/features/discovery/widgets/filter_sheet.dart';
import 'package:sawalove/shared/providers/filter_provider.dart';
import 'package:sawalove/shared/providers/discovery_provider.dart';
import 'package:sawalove/shared/providers/swipe_history_provider.dart';
import 'package:sawalove/shared/models/swipe_record.dart';
import 'package:sawalove/shared/widgets/swipe_card.dart';
import 'package:sawalove/features/discovery/controllers/super_like_controller.dart';
import 'package:sawalove/features/discovery/controllers/rewind_controller.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final PageController _pageController = PageController();

  void _onSwipe(String type, Map<String, dynamic> profile, int index) {
    final targetUid = profile['uid'] ?? profile['id'] ?? 'demo-$index';

    ref.read(swipeHistoryProvider.notifier).recordSwipe(
      SwipeRecord(
        targetUid: targetUid,
        type: type,
        profile: profile,
        timestamp: DateTime.now(),
      ),
    );

    final profiles = ref.read(discoveryProfilesProvider).value ?? [];
    if (index + 1 < profiles.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    ref.read(currentSwipeIndexProvider.notifier).state = index + 1;
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(discoveryProfilesProvider);
    final filterState = ref.watch(filterProvider);

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
                        color: Colors.red,
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
            icon: const Icon(Icons.notifications_outlined, color: SawaLoveTheme.onSurface),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: profilesAsync.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return _EmptyState();
          }
          return _SwipeStack(
            profiles: profiles,
            pageController: _pageController,
            onSwipe: _onSwipe,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Could not load profiles', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(discoveryProfilesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeStack extends ConsumerWidget {
  final List<Map<String, dynamic>> profiles;
  final PageController pageController;
  final void Function(String, Map<String, dynamic>, int) onSwipe;

  const _SwipeStack({
    required this.profiles,
    required this.pageController,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentSwipeIndexProvider).clamp(0, profiles.length - 1);

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: profiles.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return SwipeCard(
              uid: profile['uid'] ?? profile['id'] ?? 'demo-$index',
              imageUrl: profile['photo'] ??
                  profile['avatar_url'] ??
                  'https://picsum.photos/800/1200?random=$index',
              name: profile['name'] ?? 'Unknown',
              age: profile['age'] ?? 25,
              location: profile['location'] ?? profile['city'] ?? 'Cameroon',
              village: profile['village'] ?? 'Cameroon',
              goal: profile['goal'] ?? profile['intent'] ?? 'Connection',
              bio: profile['bio'] ?? 'New to SawaLove.',
            );
          },
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _SwipeControls(
            profiles: profiles,
            currentIndex: currentIndex,
            onSwipe: onSwipe,
          ),
        ),
      ],
    );
  }
}

class _SwipeControls extends ConsumerWidget {
  final List<Map<String, dynamic>> profiles;
  final int currentIndex;
  final void Function(String, Map<String, dynamic>, int) onSwipe;

  const _SwipeControls({
    required this.profiles,
    required this.currentIndex,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = profiles[currentIndex];
    final targetUid = profile['uid'] ?? profile['id'] ?? 'demo-$currentIndex';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Rewind
        _ActionButton(
          icon: Icons.refresh,
          color: const Color(0xFFFFC107),
          size: 48,
          onTap: () => RewindController.initiate(context, ref: ref),
          tooltip: 'Undo',
        ),
        // Nope
        _ActionButton(
          icon: Icons.close,
          color: Colors.red,
          size: 64,
          onTap: () => onSwipe('nope', profile, currentIndex),
          tooltip: 'Pass',
        ),
        // Super Like
        _ActionButton(
          icon: Icons.star,
          color: SawaLoveTheme.secondary,
          size: 48,
          onTap: () => SuperLikeController.initiate(context, targetUid, profile, ref: ref),
          tooltip: 'Super Like',
        ),
        // Like
        _ActionButton(
          icon: Icons.favorite,
          color: SawaLoveTheme.primary,
          size: 64,
          onTap: () => onSwipe('like', profile, currentIndex),
          tooltip: 'Like',
        ),
        // Boost
        _ActionButton(
          icon: Icons.bolt,
          color: Colors.amber,
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: SawaLoveTheme.onSurfaceVariant),
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
