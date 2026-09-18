import 'package:flutter/foundation.dart';

@immutable
class Sticker {
  final String id;
  final String url;
  final String previewUrl;
  final String name;
  final String description;

  const Sticker({
    required this.id,
    required this.url,
    required this.previewUrl,
    required this.name,
    required this.description,
  });

  factory Sticker.fromFirestore(Map<String, dynamic> data, String id) {
    return Sticker(
      id: id,
      url: data['url'] ?? '',
      previewUrl: data['previewUrl'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
