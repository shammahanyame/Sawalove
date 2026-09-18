import 'package:flutter/foundation.dart';

@immutable
class GifResult {
  final String id;
  final String previewUrl;
  final String gifUrl;
  final double aspectRatio;

  const GifResult({
    required this.id,
    required this.previewUrl,
    required this.gifUrl,
    required this.aspectRatio,
  });

  factory GifResult.fromMap(Map<String, dynamic> map) {
    final previewUrl = _readString(map, const [
      'previewUrl',
      'preview_url',
      'tinyGifUrl',
      'nanogif',
      'thumbnail',
    ]);
    final gifUrl = _readString(map, const [
      'gifUrl',
      'gif_url',
      'url',
      'mediumgif',
      'gif',
    ]);

    return GifResult(
      id: _readString(map, const ['id']),
      previewUrl: previewUrl,
      gifUrl: gifUrl,
      aspectRatio: _readAspectRatio(map),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'previewUrl': previewUrl,
        'gifUrl': gifUrl,
        'aspectRatio': aspectRatio,
      };

  static String _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final mediaFormats = map['media_formats'];
    if (mediaFormats is Map) {
      for (final format in ['tinygif', 'gif', 'mediumgif', 'nanogif']) {
        final value = mediaFormats[format];
        if (value is Map) {
          final url = value['url'];
          if (url is String && url.isNotEmpty) {
            return url;
          }
        }
      }
    }

    return '';
  }

  static double _readAspectRatio(Map<String, dynamic> map) {
    final ratio = map['aspectRatio'] ?? map['aspect_ratio'];
    if (ratio is num && ratio > 0) {
      return ratio.toDouble();
    }

    final width = map['width'];
    final height = map['height'];
    if (width is num && height is num && height > 0) {
      return width / height;
    }

    return 1.33;
  }
}
