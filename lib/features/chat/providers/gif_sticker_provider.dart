import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sticker.dart';
import '../models/sticker_pack.dart';

/// Offline sticker state. The GIF half of the picker was removed: it had no
/// provider or API key behind it, so it could only ever render an empty grid.
class GifStickerState {
  final List<StickerPack> packs;
  final int selectedPackIndex;

  const GifStickerState({
    this.packs = const [],
    this.selectedPackIndex = 0,
  });

  GifStickerState copyWith({
    List<StickerPack>? packs,
    int? selectedPackIndex,
  }) {
    return GifStickerState(
      packs: packs ?? this.packs,
      selectedPackIndex: selectedPackIndex ?? this.selectedPackIndex,
    );
  }
}

class GifStickerNotifier extends StateNotifier<GifStickerState> {
  GifStickerNotifier() : super(const GifStickerState()) {
    loadStickerPacks();
  }

  Future<void> loadStickerPacks() async {
    state = state.copyWith(packs: _defaultPacks());
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

}

final gifStickerProvider =
    StateNotifierProvider<GifStickerNotifier, GifStickerState>((ref) {
  return GifStickerNotifier();
});
