import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import 'models/gif_result.dart';
import 'models/sticker.dart';
import 'providers/gif_sticker_provider.dart';

class GifStickerPicker extends ConsumerStatefulWidget {
  const GifStickerPicker({super.key});

  @override
  ConsumerState<GifStickerPicker> createState() => _GifStickerPickerState();
}

class _GifStickerPickerState extends ConsumerState<GifStickerPicker>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref
            .read(gifStickerProvider.notifier)
            .switchTab(PickerTab.values[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _Header(
              tabController: _tabController,
              searchController: _searchController,
              onSearchChanged:
                  ref.read(gifStickerProvider.notifier).onQueryChanged,
              onClose: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _GifGrid(state: state),
                  _StickerGrid(state: state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.tabController,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClose,
  });

  final TabController tabController;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: tabController,
                  tabs: const [
                    Tab(text: 'GIFs'),
                    Tab(text: 'Stickers'),
                  ],
                  indicatorColor: SawaLoveTheme.primary,
                  labelColor: SawaLoveTheme.primary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  unselectedLabelColor: SawaLoveTheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search GIFs',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: SawaLoveTheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _GifGrid extends ConsumerWidget {
  const _GifGrid({required this.state});

  final GifStickerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gifStickerProvider.notifier);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: state.trendingChips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final chip = state.trendingChips[index];
              final selected = chip == state.selectedChip;
              return ChoiceChip(
                label: Text(chip),
                selected: selected,
                onSelected: (_) => notifier.selectChip(selected ? null : chip),
                selectedColor: SawaLoveTheme.primaryContainer,
                labelStyle: TextStyle(
                  color: selected
                      ? SawaLoveTheme.onSurface
                      : SawaLoveTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: state.isLoading && state.gifs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.gifs.isEmpty
                  ? const _EmptyState(
                      icon: Icons.gif_box_outlined,
                      title: 'No GIFs found',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: state.gifs.length,
                      itemBuilder: (context, index) {
                        return _GifTile(gif: state.gifs[index]);
                      },
                    ),
        ),
      ],
    );
  }
}

class _GifTile extends StatelessWidget {
  const _GifTile({required this.gif});

  final GifResult gif;

  @override
  Widget build(BuildContext context) {
    final imageUrl = gif.previewUrl.isNotEmpty ? gif.previewUrl : gif.gifUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.pop(context, gif),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => const ColoredBox(
            color: SawaLoveTheme.surfaceContainerHighest,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => const ColoredBox(
            color: SawaLoveTheme.surfaceContainerHighest,
            child: Icon(Icons.broken_image_outlined),
          ),
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

// Usage: showModalBottomSheet(context: context, builder: (_) => const GifStickerPicker());
