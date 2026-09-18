import 'package:flutter/foundation.dart';
import 'sticker.dart';

@immutable
class StickerPack {
  final String id;
  final String name;
  final String emojiIcon;
  final bool isPremium;
  final List<Sticker> stickers;

  const StickerPack({
    required this.id,
    required this.name,
    required this.emojiIcon,
    this.isPremium = false,
    required this.stickers,
  });

  factory StickerPack.fromFirestore(Map<String, dynamic> data, String id) {
    final stickerData = data['stickers'] as List<dynamic>? ?? [];
    final stickers = stickerData.map((d) => Sticker.fromFirestore(d as Map<String, dynamic>, d['id'] ?? '')).toList();
    return StickerPack(
      id: id,
      name: data['name'] ?? '',
      emojiIcon: data['emojiIcon'] ?? '',
      isPremium: data['isPremium'] ?? false,
      stickers: stickers,
    );
  }
}
