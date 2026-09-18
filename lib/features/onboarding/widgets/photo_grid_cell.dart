// lib/features/onboarding/widgets/photo_grid_cell.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/photo_slot.dart';
import 'face_check_badge.dart';

class PhotoGridCell extends StatelessWidget {
  final int index;
  final PhotoSlot? slot;
  final bool isMain;
  final bool isReorderMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onReplace;

  const PhotoGridCell({
    super.key,
    required this.index,
    this.slot,
    this.isMain = false,
    this.isReorderMode = false,
    this.onTap,
    this.onLongPress,
    this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final bool filled = slot != null && slot!.isFilled;
    final borderRadius = isMain ? 14.0 : 12.0;

    Widget content;
    if (!filled) {
      content = _EmptyCell(borderRadius: borderRadius, index: index);
    } else {
      content = _FilledCell(
        slot: slot!,
        borderRadius: borderRadius,
        isMain: isMain,
        isReorderMode: isReorderMode,
        onReplace: onReplace,
      );
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Semantics(
        label: filled
            ? 'Photo ${index + 1} of 6. Face ${slot!.faceDetected ? "detected" : "not detected"}. Double tap to replace.'
            : 'Empty photo slot ${index + 1}. Double tap to add a photo.',
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
        border: isReorderMode && filled
                ? Border.all(color: SawaLoveTheme.outlineVariant, style: BorderStyle.solid, width: 2)
                : (!filled
                    ? Border.all(color: SawaLoveTheme.surfaceContainerHighest, style: BorderStyle.solid, width: 2)
                    : null),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  content,
                  if (isReorderMode && filled)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCell extends StatelessWidget {
  final double borderRadius;
  final int index;

  const _EmptyCell({required this.borderRadius, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SawaLoveTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: SawaLoveTheme.surfaceContainerHighest,
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add,
            color: SawaLoveTheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            'Add photo',
            style: TextStyle(
              color: SawaLoveTheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledCell extends StatelessWidget {
  final PhotoSlot slot;
  final double borderRadius;
  final bool isMain;
  final bool isReorderMode;
  final VoidCallback? onReplace;

  const _FilledCell({
    required this.slot,
    required this.borderRadius,
    required this.isMain,
    required this.isReorderMode,
    this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (slot.localFile != null && slot.url == null) {
      image = Image.file(
        File(slot.localFile!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (slot.url != null) {
      image = CachedNetworkImage(
        imageUrl: slot.url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => Container(
          color: SawaLoveTheme.surfaceContainerLow,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => Container(
          color: SawaLoveTheme.surfaceContainerLow,
          child: const Icon(Icons.error),
        ),
      );
    } else {
      image = Container(color: SawaLoveTheme.surfaceContainerLow);
    }

    final bool showFailedOverlay = slot.checkStatus == PhotoCheckStatus.failed;

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        if (showFailedOverlay)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.face_retouching_off, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onReplace,
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                    label: const Text(
                      'Replace photo',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: SawaLoveTheme.errorColor.withValues(alpha: 0.9),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Upload progress
        if (slot.uploadProgress < 1.0)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: CircularProgressIndicator(
                value: slot.uploadProgress > 0 ? slot.uploadProgress : null,
                color: SawaLoveTheme.primary,
                strokeWidth: 3,
              ),
            ),
          ),
        // Face check badge
        if (slot.uploadProgress >= 1.0 && slot.checkStatus != PhotoCheckStatus.failed)
          Positioned(
            bottom: 6,
            left: 6,
            child: FaceCheckBadge(
              type: slot.checkStatus == PhotoCheckStatus.passed
                  ? FaceCheckType.detected
                  : FaceCheckType.checking,
            ),
          ),
        // Reorder handle
        if (isReorderMode)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.drag_handle, color: Colors.white, size: 18),
            ),
          ),
      ],
    );
  }
}

