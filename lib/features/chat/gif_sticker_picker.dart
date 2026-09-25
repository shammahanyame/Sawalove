import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import 'models/sticker.dart';
import 'providers/gif_sticker_provider.dart';

/// Offline emoji sticker picker. Picking a sticker pops it to the caller,
/// which sends it as a chat message.
///
/// The old GIF tab was removed: it had no API provider or key behind it and
/// could only ever render an empty grid (a fake feature — Play's Deceptive
/// Behaviour policy treats that as grounds for removal).
class GifStickerPicker extends ConsumerWidget {
  const GifStickerPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gifStickerProvider);

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.62,
        decoration: const BoxDecoration(
          color: SawaLoveTheme.surfaceContainerLow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Stickers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Expanded(child: _StickerGrid(state: state)),
          ],
        ),
      ),
    );
  }
}

class _StickerGrid extends ConsumerWidget {
  const _StickerGrid({required this.state});

  final GifStickerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.packs.isEmpty) {
      return const _EmptyState(
        icon: Icons.emoji_emotions_outlined,
        title: 'No stickers available',
      );
    }

    final selectedIndex =
        state.selectedPackIndex.clamp(0, state.packs.length - 1).toInt();
    final selectedPack = state.packs[selectedIndex];

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: state.packs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final pack = state.packs[index];
              final selected = index == selectedIndex;
              return ChoiceChip(
                avatar: Text(pack.emojiIcon),
                label: Text(pack.name),
                selected: selected,
                onSelected: (_) =>
                    ref.read(gifStickerProvider.notifier).selectPack(index),
                selectedColor: SawaLoveTheme.primaryContainer,
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: selectedPack.stickers.length,
            itemBuilder: (context, index) {
              return _StickerTile(sticker: selectedPack.stickers[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({required this.sticker});

  final Sticker sticker;

  @override
  Widget build(BuildContext context) {
    final isNetworkSticker = sticker.previewUrl.startsWith('http') ||
        sticker.url.startsWith('http');
    final imageUrl =
        sticker.previewUrl.isNotEmpty ? sticker.previewUrl : sticker.url;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.pop(context, sticker),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SawaLoveTheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isNetworkSticker
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) =>
                      const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined),
                )
              : Text(
                  imageUrl,
                  style: const TextStyle(fontSize: 28),
                ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: SawaLoveTheme.onSurfaceVariant, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: SawaLoveTheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
