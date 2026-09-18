// lib/features/onboarding/photo_upload_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/photo_slot.dart';
import '../../shared/providers/photo_upload_provider.dart';
import 'widgets/photo_grid_cell.dart';
import 'widgets/photo_progress_bar.dart';

class PhotoUploadScreen extends ConsumerStatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  ConsumerState<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends ConsumerState<PhotoUploadScreen> {
  void _showPhotoSourcePicker(int slotIndex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Photo / Ajouter une photo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _SourceButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(ctx);
                        ref.read(photoUploadProvider.notifier).pickPhoto(slotIndex, ImageSource.camera);
                      },
                    ),
                    const SizedBox(width: 12),
                    _SourceButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        ref.read(photoUploadProvider.notifier).pickPhoto(slotIndex, ImageSource.gallery);
                      },
                    ),
                    const SizedBox(width: 12),
                    _SourceButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Instagram',
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Instagram import coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCellTap(int index, PhotoSlot? slot) {
    final state = ref.read(photoUploadProvider);
    if (state.isReorderMode) return;

    if (slot == null || slot.isEmpty) {
      _showPhotoSourcePicker(index);
    } else if (slot.checkStatus == PhotoCheckStatus.failed) {
      ref.read(photoUploadProvider.notifier).replacePhoto(index);
      _showPhotoSourcePicker(index);
    } else {
      _showPhotoSourcePicker(index);
    }
  }

  void _handleLongPress(int index) {
    final state = ref.read(photoUploadProvider);
    final slot = state.slots[index];
    if (slot != null && slot.isFilled && !state.isReorderMode) {
      ref.read(photoUploadProvider.notifier).enterReorderMode();
    }
  }

  Widget _buildNormalGrid(List<PhotoSlot?> slots) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cellSize = (constraints.maxWidth - 2 * spacing) / 3;
        final largeSize = 2 * cellSize + spacing;

        Widget cell(int index, double width, double height, {bool isMain = false}) {
          final slot = slots[index];
          return SizedBox(
            width: width,
            height: height,
            child: PhotoGridCell(
              key: ValueKey('photo_slot_$index'),
              index: index,
              slot: slot,
              isMain: isMain,
              isReorderMode: false,
              onTap: () => _handleCellTap(index, slot),
              onLongPress: () => _handleLongPress(index),
              onReplace: () {
                ref.read(photoUploadProvider.notifier).replacePhoto(index);
                _showPhotoSourcePicker(index);
              },
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cell(0, largeSize, largeSize, isMain: true),
                const SizedBox(width: spacing),
                Column(
                  children: [
                    cell(1, cellSize, cellSize),
                    const SizedBox(height: spacing),
                    cell(2, cellSize, cellSize),
                  ],
                ),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              children: [
                cell(3, cellSize, cellSize),
                const SizedBox(width: spacing),
                cell(4, cellSize, cellSize),
                const SizedBox(width: spacing),
                cell(5, cellSize, cellSize),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildReorderGrid(List<PhotoSlot?> slots) {
    final children = List.generate(6, (index) {
      final slot = slots[index];
      return PhotoGridCell(
        key: ValueKey('photo_slot_$index'),
        index: index,
        slot: slot,
        isMain: index == 0,
        isReorderMode: true,
        onTap: () => _handleCellTap(index, slot),
        onLongPress: () => _handleLongPress(index),
        onReplace: () {
          ref.read(photoUploadProvider.notifier).replacePhoto(index);
          _showPhotoSourcePicker(index);
        },
      );
    });

    return ReorderableGridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: children,
      onReorder: (oldIndex, newIndex) {
        final previousMain = ref.read(photoUploadProvider).slots[0];
        ref.read(photoUploadProvider.notifier).reorderPhotos(oldIndex, newIndex);
        final newMain = ref.read(photoUploadProvider).slots[0];
        if (previousMain != newMain && newMain != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New main photo set / Nouvelle photo principale définie.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoUploadProvider);
    final slots = state.slots;
    final filledCount = state.filledCount;
    final canContinue = state.canContinue;
    final isReorderMode = state.isReorderMode;

    // Face check failure banner
    final failedSlots = slots.asMap().entries.where((e) => e.value?.checkStatus == PhotoCheckStatus.failed);
    final bool showFailureBanner = failedSlots.isNotEmpty;

    return Scaffold(
      backgroundColor: SawaLoveTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isReorderMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(photoUploadProvider.notifier).exitReorderMode(),
              )
            : null,
        title: Text(
          isReorderMode ? 'Reorder Photos / Réorganiser' : 'Add Your Photos',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          if (!isReorderMode)
            TextButton(
              onPressed: () {
                // Demo helper: cycle through states
                _showDemoMenu();
              },
              child: const Text('Demo'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReorderMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: SawaLoveTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SawaLoveTheme.outlineVariant),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Drag photos to reorder. The large slot is your main photo.\n'
                          'Glissez les photos pour les réorganiser. La grande case est votre photo principale.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isReorderMode) ...[
                Text(
                  'Min 2 photos, clear face required / Min 2 photos, visage clair requis',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: SawaLoveTheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
              ],
              // Photo grid
              if (isReorderMode)
                _buildReorderGrid(slots)
              else
                _buildNormalGrid(slots),
              const SizedBox(height: 20),
              // Failure banner
              if (showFailureBanner)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SawaLoveTheme.errorColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SawaLoveTheme.errorColor.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Face not detected / Visage non détecté',
                        style: TextStyle(
                          color: SawaLoveTheme.errorColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Please upload a photo where your face is clearly visible. '
                        'Veuillez télécharger une photo où votre visage est clairement visible.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Progress bar
              PhotoProgressBar(count: filledCount),
              const Spacer(),
              // CTA
              if (isReorderMode)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => ref.read(photoUploadProvider.notifier).exitReorderMode(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SawaLoveTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: const Text(
                      'Done / Terminé',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: canContinue
                        ? () => context.go('/onboarding/preferences')
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SawaLoveTheme.primary,
                      disabledBackgroundColor: SawaLoveTheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text(
                      filledCount < 2
                          ? 'Add ${2 - filledCount} more photo${2 - filledCount > 1 ? 's' : ''}'
                          : filledCount >= 2 && !canContinue
                              ? 'Checking photos…'
                              : 'Continue to Preferences',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDemoMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Demo States')), 
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Empty (0 photos)'),
                onTap: () {
                  ref.read(photoUploadProvider.notifier).clearAll();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.looks_one),
                title: const Text('1 Photo'),
                onTap: () {
                  ref.read(photoUploadProvider.notifier).clearAll();
                  ref.read(photoUploadProvider.notifier).mockAddPhoto(0);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.face),
                title: const Text('Face Check (checking)'),
                onTap: () {
                  ref.read(photoUploadProvider.notifier).clearAll();
                  ref.read(photoUploadProvider.notifier).mockSetChecking(0);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.error_outline),
                title: const Text('Face Check (failed)'),
                onTap: () {
                  ref.read(photoUploadProvider.notifier).clearAll();
                  ref.read(photoUploadProvider.notifier).mockSetFaceFailed(0);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('All 6 Added'),
                onTap: () {
                  ref.read(photoUploadProvider.notifier).mockAddAllPhotos();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.drag_handle),
                title: const Text('Enter Reorder Mode'),
                onTap: () {
                  ref.read(photoUploadProvider.notifier).mockAddAllPhotos();
                  ref.read(photoUploadProvider.notifier).enterReorderMode();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: SawaLoveTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SawaLoveTheme.surfaceContainerHighest),
          ),
          child: Column(
            children: [
              Icon(icon, color: SawaLoveTheme.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: SawaLoveTheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

