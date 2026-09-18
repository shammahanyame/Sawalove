// lib/shared/models/photo_slot.dart

import 'package:flutter/foundation.dart';

enum PhotoCheckStatus { pending, passed, failed }

@immutable
class PhotoSlot {
  final String? url;
  final String? localFile;
  final String? caption;
  final bool faceDetected;
  final PhotoCheckStatus checkStatus;
  final double uploadProgress;

  const PhotoSlot({
    this.url,
    this.localFile,
    this.caption,
    this.faceDetected = false,
    this.checkStatus = PhotoCheckStatus.pending,
    this.uploadProgress = 0.0,
  });

  PhotoSlot copyWith({
    String? url,
    String? localFile,
    String? caption,
    bool? faceDetected,
    PhotoCheckStatus? checkStatus,
    double? uploadProgress,
  }) {
    return PhotoSlot(
      url: url ?? this.url,
      localFile: localFile ?? this.localFile,
      caption: caption ?? this.caption,
      faceDetected: faceDetected ?? this.faceDetected,
      checkStatus: checkStatus ?? this.checkStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  bool get isEmpty => url == null && localFile == null;
  bool get isFilled => !isEmpty;
}

