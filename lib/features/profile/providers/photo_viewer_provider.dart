import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks viewer-level state: current index, zoom state, and pinch-hint visibility.
final photoViewerProvider =
    StateNotifierProvider.autoDispose<PhotoViewerNotifier, PhotoViewerState>(
  (ref) => PhotoViewerNotifier(),
);

class PhotoViewerState {
  final int currentIndex;
  final bool isZoomed;
  final bool showPinchHint;
  final bool disableAnimations;

  const PhotoViewerState({
    this.currentIndex = 0,
    this.isZoomed = false,
    this.showPinchHint = false,
    this.disableAnimations = false,
  });

  PhotoViewerState copyWith({
    int? currentIndex,
    bool? isZoomed,
    bool? showPinchHint,
    bool? disableAnimations,
  }) {
    return PhotoViewerState(
      currentIndex: currentIndex ?? this.currentIndex,
      isZoomed: isZoomed ?? this.isZoomed,
      showPinchHint: showPinchHint ?? this.showPinchHint,
      disableAnimations: disableAnimations ?? this.disableAnimations,
    );
  }
}

class PhotoViewerNotifier extends StateNotifier<PhotoViewerState> {
  PhotoViewerNotifier() : super(const PhotoViewerState());

  static const _kPinchHintKey = 'photo_viewer_pinch_hint_seen';

  Future<void> init({required int initialIndex}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_kPinchHintKey) ?? false;
    state = state.copyWith(
      currentIndex: initialIndex,
      showPinchHint: !hasSeen,
    );
    if (!hasSeen) {
      // Auto-dismiss after 3 seconds and persist flag.
      Future.delayed(const Duration(seconds: 3), () async {
        if (mounted) {
          state = state.copyWith(showPinchHint: false);
          final p = await SharedPreferences.getInstance();
          await p.setBool(_kPinchHintKey, true);
        }
      });
    }
  }

  void setIndex(int index) => state = state.copyWith(currentIndex: index);

  void setZoomed(bool zoomed) => state = state.copyWith(isZoomed: zoomed);

  void dismissHint() => state = state.copyWith(showPinchHint: false);

  void setDisableAnimations(bool value) =>
      state = state.copyWith(disableAnimations: value);
}
