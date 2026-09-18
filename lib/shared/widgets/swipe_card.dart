import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sawalove/features/discovery/controllers/super_like_controller.dart';

class SwipeCard extends ConsumerWidget {
  final String imageUrl;
  final String name;
  final int age;
  final String location;
  final String village;
  final String goal;
  final String bio;
  final String uid;
  final VoidCallback? onLike;
  final VoidCallback? onPass;

  const SwipeCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.age,
    required this.location,
    required this.village,
    required this.goal,
    required this.bio,
    required this.uid,
    this.onLike,
    this.onPass,
  });

  Map<String, dynamic> get _profile => {
        'photo': imageUrl,
        'name': name,
        'age': age,
        'location': location,
        'village': village,
        'goal': goal,
        'bio': bio,
        'verified': true,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -800) {
          // Upward swipe with velocity > 800 px/s
          SuperLikeController.initiate(
            context,
            uid,
            _profile,
            ref: ref,
          );
        }
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Profile Image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.person, size: 100),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.error, size: 100),
                ),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.6, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Profile Info
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$name, $age',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(location, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_city, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text('Village: $village', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text('Goal: $goal', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bio,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
