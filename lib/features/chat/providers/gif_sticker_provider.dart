import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gif_result.dart';
import '../models/sticker.dart';
import '../models/sticker_pack.dart';

enum PickerTab { gif, sticker }

const _noSelectedChipChange = Object();

class GifStickerState {
  final PickerTab currentTab;
  final String query;
  final bool isLoading;
  final List<GifResult> gifs;
  final List<StickerPack> packs;
  final int selectedPackIndex;
  final List<String> trendingChips;
  final String? selectedChip;

  const GifStickerState({
    this.currentTab = PickerTab.gif,
    this.query = '',
    this.isLoading = false,
    this.gifs = const [],
    this.packs = const [],
    this.selectedPackIndex = 0,
    this.trendingChips = const [
      'Trending',
      'Funny',
      'Love',
      'Dance',
      'African',
      'Party',
      'Crying',
      'Strong',
    ],
    this.selectedChip,
  });

  GifStickerState copyWith({
    PickerTab? currentTab,
    String? query,
    bool? isLoading,
    List<GifResult>? gifs,
    List<StickerPack>? packs,
    int? selectedPackIndex,
    Object? selectedChip = _noSelectedChipChange,
  }) {
    return GifStickerState(
      currentTab: currentTab ?? this.currentTab,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      gifs: gifs ?? this.gifs,
      packs: packs ?? this.packs,
      selectedPackIndex: selectedPackIndex ?? this.selectedPackIndex,
      selectedChip: identical(selectedChip, _noSelectedChipChange)
          ? this.selectedChip
          : selectedChip as String?,
    );
  }
}

class GifStickerNotifier extends StateNotifier<GifStickerState> {
  GifStickerNotifier(this.ref) : super(const GifStickerState()) {
    loadStickerPacks();
    loadTrendingGifs();
  }

  final Ref ref;
  Timer? _debounceTimer;

  void switchTab(PickerTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(query: query, selectedChip: null);
      if (query.trim().isNotEmpty) {
        searchGifs(query.trim());
      } else {
        loadTrendingGifs();
      }
    });
  }

  Future<void> searchGifs(String query) async {
    state = state.copyWith(isLoading: true);
    try {
      state = state.copyWith(gifs: const [], isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadTrendingGifs() async {
    await searchGifs('');
  }

  Future<void> loadStickerPacks() async {
    try {
      state = state.copyWith(packs: _defaultPacks());
    } catch (_) {
      state = state.copyWith(packs: _defaultPacks());
    }
  }

  void selectChip(String? chip) {
    state = state.copyWith(selectedChip: chip);
    if (chip == null) {
      loadTrendingGifs();
    } else {
      searchGifs(chip);
    }
  }

  void selectPack(int index) {
    state = state.copyWith(selectedPackIndex: index);
  }

  List<StickerPack> _defaultPacks() {
    const popular = StickerPack(
      id: 'popular',
      name: 'Popular',
      emojiIcon: '\u{1F525}',
      stickers: [
        Sticker(
          id: 'heart',
          url: '\u{2764}\u{FE0F}',
          previewUrl: '\u{2764}\u{FE0F}',
          name: 'Heart',
          description: 'Love',
        ),
        Sticker(
          id: 'smile',
          url: '\u{1F60D}',
          previewUrl: '\u{1F60D}',
          name: 'Smile',
          description: 'Adore',
        ),
        Sticker(
          id: 'fire',
          url: '\u{1F525}',
          previewUrl: '\u{1F525}',
          name: 'Fire',
          description: 'Hot',
        ),
        Sticker(
          id: 'laugh',
          url: '\u{1F602}',
          previewUrl: '\u{1F602}',
          name: 'Laugh',
          description: 'Funny',
        ),
        Sticker(
          id: 'pray',
          url: '\u{1F64F}',
          previewUrl: '\u{1F64F}',
          name: 'Pray',
          description: 'Prayer',
        ),
        Sticker(
          id: 'sparkles',
          url: '\u{2728}',
          previewUrl: '\u{2728}',
          name: 'Sparkles',
          description: 'Special',
        ),
      ],
    );
    const love = StickerPack(
      id: 'love',
      name: 'Love',
      emojiIcon: '\u{1F495}',
      stickers: [
        Sticker(
          id: 'two_hearts',
          url: '\u{1F495}',
          previewUrl: '\u{1F495}',
          name: 'Two hearts',
          description: 'Love',
        ),
        Sticker(
          id: 'kiss',
          url: '\u{1F618}',
          previewUrl: '\u{1F618}',
          name: 'Kiss',
          description: 'Kiss',
        ),
        Sticker(
          id: 'rose',
          url: '\u{1F339}',
          previewUrl: '\u{1F339}',
          name: 'Rose',
          description: 'Rose',
        ),
        Sticker(
          id: 'couple',
          url: '\u{1F491}',
          previewUrl: '\u{1F491}',
          name: 'Couple',
          description: 'Together',
        ),
        Sticker(
          id: 'ring',
          url: '\u{1F48D}',
          previewUrl: '\u{1F48D}',
          name: 'Ring',
          description: 'Commitment',
        ),
        Sticker(
          id: 'gift',
          url: '\u{1F381}',
          previewUrl: '\u{1F381}',
          name: 'Gift',
          description: 'Gift',
        ),
      ],
    );
    const cameroon = StickerPack(
      id: 'cameroon',
      name: 'Cameroon',
      emojiIcon: '\u{1F1E8}\u{1F1F2}',
      stickers: [
        Sticker(
          id: 'flag',
          url: '\u{1F1E8}\u{1F1F2}',
          previewUrl: '\u{1F1E8}\u{1F1F2}',
          name: 'Cameroon',
          description: 'Cameroon',
        ),
        Sticker(
          id: 'trumpet',
          url: '\u{1F3BA}',
          previewUrl: '\u{1F3BA}',
          name: 'Music',
          description: 'Music',
        ),
        Sticker(
          id: 'dance',
          url: '\u{1F57A}',
          previewUrl: '\u{1F57A}',
          name: 'Dance',
          description: 'Dance',
        ),
        Sticker(
          id: 'dress',
          url: '\u{1F457}',
          previewUrl: '\u{1F457}',
          name: 'Dress',
          description: 'Style',
        ),
        Sticker(
          id: 'palm',
          url: '\u{1F334}',
          previewUrl: '\u{1F334}',
          name: 'Palm',
          description: 'Tropical',
        ),
        Sticker(
          id: 'sunrise',
          url: '\u{1F305}',
          previewUrl: '\u{1F305}',
          name: 'Sunrise',
          description: 'Sunrise',
        ),
      ],
    );

    return const [popular, love, cameroon];
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final gifStickerProvider =
    StateNotifierProvider<GifStickerNotifier, GifStickerState>((ref) {
  return GifStickerNotifier(ref);
});
