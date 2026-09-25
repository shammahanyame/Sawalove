import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sawalove/core/theme/theme.dart';
import 'package:sawalove/shared/models/photo_slot.dart';
import 'package:sawalove/shared/providers/peer_profile_provider.dart';
import 'package:sawalove/shared/providers/quota_provider.dart';
import 'package:sawalove/shared/services/backend_service.dart';

class PeerProfileScreen extends ConsumerWidget {
  final String uid;
  const PeerProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(peerProfileProvider(uid));

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ProfileUnavailable(
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home/discover');
            }
          },
        ),
        data: (profile) {
          // null = 404 (deleted, hidden, or blocked either direction).
          if (profile == null) {
            return _ProfileUnavailable(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home/discover');
                }
              },
            );
          }
          return _ProfileView(uid: uid, profile: profile);
        },
      ),
    );
  }
}

class _ProfileView extends ConsumerWidget {
  const _ProfileView({required this.uid, required this.profile});

  final String uid;
  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = profile['name']?.toString().trim() ?? '';
    final displayName = name.isEmpty ? 'SawaLove user' : name;
    final firstName = displayName.split(' ').first;
    final age = profile['age'];
    final city = profile['city']?.toString() ?? '';
    final photo = profile['photo']?.toString() ?? '';
    final bio = profile['bio']?.toString().trim() ?? '';
    final intent = profile['intent']?.toString().trim() ?? '';
    final goal = profile['goal']?.toString().trim() ?? '';
    final village = profile['village']?.toString().trim() ?? '';
    final country = profile['country']?.toString().trim() ?? '';

    final title = age == null ? displayName : '$displayName, $age';
    final subtitle = city.isEmpty ? null : city;

    final photos = photo.isEmpty
        ? const <PhotoSlot>[]
        : [PhotoSlot(url: photo, caption: displayName)];

    final detailRows = <(IconData, String)>[
      if (village.isNotEmpty && village != country)
        (Icons.location_on, 'Village: $village'),
      if (city.isNotEmpty) (Icons.location_city, 'City: $city'),
      if (country.isNotEmpty) (Icons.language, 'Country: $country'),
      if (intent.isNotEmpty)
        (Icons.favorite_outline, 'Intent: $intent')
      else if (goal.isNotEmpty)
        (Icons.favorite_outline, 'Looking for: $goal'),
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: photos.isEmpty
                      ? null
                      : () => context.push(
                            '/profile/photos',
                            extra: {
                              'profileUid': uid,
                              'photos': photos,
                              'name': displayName,
                              'initialIndex': 0,
                              'age': age,
                              'city': city,
                            },
                          ),
                  child: photo.isEmpty
                      ? Container(
                          color: SawaLoveTheme.surfaceContainerLow,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 96,
                            color: SawaLoveTheme.onSurfaceVariant,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: photo,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: SawaLoveTheme.surfaceContainerLow,
                            child: const Icon(
                              Icons.person_rounded,
                              size: 96,
                              color: SawaLoveTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              SawaLoveTheme.primary.withValues(alpha: 0.3),
                          foregroundImage: photo.isEmpty
                              ? null
                              : CachedNetworkImageProvider(photo),
                          child: photo.isEmpty
                              ? Text(
                                  displayName.characters.first.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (sheetContext) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.flag_outlined),
                        title: const Text('Report user'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.push('/safety/report/$uid');
                        },
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.block, color: SawaLoveTheme.errorColor),
                        title: const Text('Block user'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _confirmBlock(context, ref, displayName);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About $firstName',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  bio.isEmpty ? 'No bio yet.' : bio,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: bio.isEmpty
                        ? SawaLoveTheme.onSurfaceVariant
                        : null,
                  ),
                ),
                if (detailRows.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Details',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  for (final (icon, label) in detailRows)
                    _InfoRow(icon: icon, label: label),
                ],
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Consumer(
            builder: (context, ref, child) {
              final quota = ref.watch(quotaProvider);
              final requestsRemaining = quota.requestsRemaining;
              final isPremium = quota.isPremium;
              final canMessage = requestsRemaining > 0 && isPremium;

              return Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _like(context, ref),
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Like'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canMessage
                            ? () => context.push('/request/compose/$uid')
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Upgrade to Premium to message anyone',
                                    ),
                                  ),
                                );
                              },
                        icon: Icon(canMessage ? Icons.chat : Icons.lock),
                        label: Text(canMessage ? 'Message' : 'Premium'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canMessage
                              ? SawaLoveTheme.primary
                              : SawaLoveTheme.onSurfaceVariant,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Records a real like (`POST /swipes`). The server replies with
  /// `matched=true` when the other side already liked us.
  Future<void> _like(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await ref.read(backendServiceProvider).sendSwipe(
            targetUserId: uid,
            action: 'like',
          );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.matched
                ? "It's a match! Say hello from your inbox."
                : 'Like sent',
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not send like. Please try again.')),
      );
    }
  }

  Future<void> _confirmBlock(
    BuildContext context,
    WidgetRef ref,
    String displayName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Block user?'),
        content: Text(
          'Block $displayName? They will no longer see your profile, and '
          'your matches and chats with them will be hidden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: SawaLoveTheme.errorColor,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(backendServiceProvider).blockUser(uid);
      messenger.showSnackBar(
        SnackBar(content: Text('$displayName has been blocked.')),
      );
      // The profile is now a 404 for us — leave it.
      if (context.mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home/discover');
        }
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not block this user. Please try again.')),
      );
    }
  }
}

class _ProfileUnavailable extends StatelessWidget {
  const _ProfileUnavailable({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_rounded,
                size: 64,
                color: SawaLoveTheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profile unavailable',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'This profile may have been removed, paused, or hidden.',
                textAlign: TextAlign.center,
                style: TextStyle(color: SawaLoveTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onBack, child: const Text('Go back')),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
