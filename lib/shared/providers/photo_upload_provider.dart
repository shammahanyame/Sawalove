// lib/shared/providers/photo_upload_provider.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo_slot.dart';
import '../services/firebase_service.dart';

class PhotoUploadState {
  final List<PhotoSlot?> slots;
  final bool isReorderMode;
  final bool isUploading;

  const PhotoUploadState({
    required this.slots,
    this.isReorderMode = false,
    this.isUploading = false,
  });

  PhotoUploadState copyWith({
    List<PhotoSlot?>? slots,
    bool? isReorderMode,
    bool? isUploading,
  }) {
    return PhotoUploadState(
      slots: slots ?? this.slots,
      isReorderMode: isReorderMode ?? this.isReorderMode,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  int get filledCount => slots.whereType<PhotoSlot>().length;

  bool get canContinue {
    final filled = slots.whereType<PhotoSlot>();
    return filled.length >= 2 &&
        filled.every((s) => s.checkStatus != PhotoCheckStatus.failed) &&
        filled.every((s) => s.checkStatus != PhotoCheckStatus.pending);
  }

  bool get mainPhotoHasFace {
    final main = slots[0];
    return main != null && main.faceDetected;
  }
}

class PhotoUploadNotifier extends StateNotifier<PhotoUploadState> {
  final Ref _ref;

  PhotoUploadNotifier(this._ref)
      : super(
          const PhotoUploadState(slots: [null, null, null, null, null, null]),
        );

  final ImagePicker _picker = ImagePicker();

  Future<void> pickPhoto(int slotIndex, ImageSource source) async {
    final XFile? picked =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      try {
        await uploadPhoto(File(picked.path), slotIndex);
      } catch (_) {
        _markSlotFailed(File(picked.path), slotIndex);
      }
    }
  }

  Future<void> uploadPhoto(File imageFile, int slotIndex) async {
    // 1. Set uploading state
    final newSlots = List<PhotoSlot?>.from(state.slots);
    newSlots[slotIndex] = PhotoSlot(
      localFile: imageFile.path,
      checkStatus: PhotoCheckStatus.pending,
      uploadProgress: 0.0,
    );
    state = state.copyWith(slots: newSlots, isUploading: true);

    // 2. Compress
    await Future.delayed(const Duration(milliseconds: 300)); // simulate
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: 85,
      minWidth: 1200,
      minHeight: 1200,
    );
    final Uint8List uploadBytes = compressed ?? await imageFile.readAsBytes();

    // Simulate upload progress
    for (double p = 0.2; p <= 0.8; p += 0.2) {
      await Future.delayed(const Duration(milliseconds: 100));
      final progressSlots = List<PhotoSlot?>.from(state.slots);
      progressSlots[slotIndex] =
          progressSlots[slotIndex]!.copyWith(uploadProgress: p);
      state = state.copyWith(slots: progressSlots);
    }

    // 3. Face detection placeholder
    await Future.delayed(const Duration(milliseconds: 400));
    final bool hasFace = _simulateFaceDetection();

    if (!hasFace && slotIndex == 0) {
      // Main photo must have face
      final failSlots = List<PhotoSlot?>.from(state.slots);
      failSlots[slotIndex] = PhotoSlot(
        localFile: imageFile.path,
        checkStatus: PhotoCheckStatus.failed,
        faceDetected: false,
        uploadProgress: 1.0,
      );
      state = state.copyWith(slots: failSlots, isUploading: false);
      throw PhotoException('main_no_face');
    }

    // 4. Upload to Supabase Storage when configured. Demo mode keeps the local file.
    final uploadedUrl =
        await _ref.read(firebaseServiceProvider).uploadProfilePhoto(
              bytes: uploadBytes,
              slotIndex: slotIndex,
            );

    final finalSlots = List<PhotoSlot?>.from(state.slots);
    finalSlots[slotIndex] = PhotoSlot(
      url: uploadedUrl,
      localFile: imageFile.path,
      faceDetected: hasFace,
      checkStatus: hasFace ? PhotoCheckStatus.passed : PhotoCheckStatus.failed,
      uploadProgress: 1.0,
    );
    state = state.copyWith(slots: finalSlots, isUploading: false);
  }

  bool _simulateFaceDetection() {
    // Do not randomly reject real users. Replace with device or server liveness
    // verification before enforcing face checks in production.
    return true;
  }

  void _markSlotFailed(File imageFile, int slotIndex) {
    final failSlots = List<PhotoSlot?>.from(state.slots);
    failSlots[slotIndex] = PhotoSlot(
      localFile: imageFile.path,
      checkStatus: PhotoCheckStatus.failed,
      faceDetected: false,
      uploadProgress: 1.0,
    );
    state = state.copyWith(slots: failSlots, isUploading: false);
  }

  void replacePhoto(int slotIndex) {
    final newSlots = List<PhotoSlot?>.from(state.slots);
    newSlots[slotIndex] = null;
    state = state.copyWith(slots: newSlots);
  }

  void enterReorderMode() {
    state = state.copyWith(isReorderMode: true);
  }

  void exitReorderMode() {
    state = state.copyWith(isReorderMode: false);
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final newSlots = List<PhotoSlot?>.from(state.slots);
    final item = newSlots.removeAt(oldIndex);
    newSlots.insert(newIndex, item);
    state = state.copyWith(slots: newSlots);
  }

  void mockAddPhoto(int slotIndex) {
    final newSlots = List<PhotoSlot?>.from(state.slots);
    newSlots[slotIndex] = PhotoSlot(
      url: 'https://picsum.photos/400?random=$slotIndex',
      faceDetected: true,
      checkStatus: PhotoCheckStatus.passed,
      uploadProgress: 1.0,
    );
    state = state.copyWith(slots: newSlots);
  }

  void mockSetChecking(int slotIndex) {
    final newSlots = List<PhotoSlot?>.from(state.slots);
    newSlots[slotIndex] = PhotoSlot(
      url: 'https://picsum.photos/400?random=$slotIndex',
      faceDetected: false,
      checkStatus: PhotoCheckStatus.pending,
      uploadProgress: 1.0,
    );
    state = state.copyWith(slots: newSlots);
  }

  void mockSetFaceFailed(int slotIndex) {
    final newSlots = List<PhotoSlot?>.from(state.slots);
    newSlots[slotIndex] = PhotoSlot(
      url: 'https://picsum.photos/400?random=$slotIndex',
      faceDetected: false,
      checkStatus: PhotoCheckStatus.failed,
      uploadProgress: 1.0,
    );
    state = state.copyWith(slots: newSlots);
  }

  void mockAddAllPhotos() {
    final newSlots = List<PhotoSlot?>.from(state.slots);
    for (int i = 0; i < 6; i++) {
      newSlots[i] = PhotoSlot(
        url: 'https://picsum.photos/400?random=$i',
        faceDetected: true,
        checkStatus: PhotoCheckStatus.passed,
        uploadProgress: 1.0,
      );
    }
    state = state.copyWith(slots: newSlots);
  }

  void clearAll() {
    state = const PhotoUploadState(slots: [null, null, null, null, null, null]);
  }
}

class PhotoException implements Exception {
  final String code;
  PhotoException(this.code);
  @override
  String toString() => 'PhotoException($code)';
}

final photoUploadProvider =
    StateNotifierProvider<PhotoUploadNotifier, PhotoUploadState>((ref) {
  return PhotoUploadNotifier(ref);
});
