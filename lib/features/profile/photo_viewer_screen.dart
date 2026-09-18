import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/models/photo_slot.dart';
import '../../../shared/providers/like_provider.dart';
import 'providers/photo_viewer_provider.dart';
import 'package:sawalove/l10n/app_localizations.dart';

class PhotoViewerScreen extends ConsumerStatefulWidget {
  final String profileUid;
  final int initialIndex;
  final List<PhotoSlot> photos;
  final String name;
  final int? age;
  final String? city;
  final List<String>? badges;

  const PhotoViewerScreen({
    super.key,
    required this.profileUid,
    this.initialIndex = 0,
    required this.photos,
    required this.name,
    this.age,
    this.city,
    this.badges,
  });

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late ScrollController _thumbController;
  late AnimationController _heartController;
  final List<TransformationController> _transformControllers = [];
  TapDownDetails? _lastTapDownDetails;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _safeInitialIndex);
    _thumbController = ScrollController();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    for (int i = 0; i < widget.photos.length; i++) {
      final ctrl = TransformationController();
      ctrl.addListener(() => _onTransformChanged(i, ctrl));
      _transformControllers.add(ctrl);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(photoViewerProvider.notifier)
          .init(initialIndex: _safeInitialIndex);
      _scrollThumbnailIntoView(_safeInitialIndex);
      _hideSystemUI();
    });
  }

  int get _safeInitialIndex {
    if (widget.photos.isEmpty) return 0;
    return widget.initialIndex.clamp(0, widget.photos.length - 1).toInt();
  }

  void _onTransformChanged(int index, TransformationController ctrl) {
    final scale = ctrl.value.getMaxScaleOnAxis();
    final isZoomed = scale > 1.05;
    if (index == ref.read(photoViewerProvider).currentIndex) {
      ref.read(photoViewerProvider.notifier).setZoomed(isZoomed);
    }
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _scrollThumbnailIntoView(int index) {
    if (!_thumbController.hasClients || widget.photos.length <= 1) return;
    const itemWidth = 52.0 + 8.0;
    final offset = index * itemWidth -
        (MediaQuery.of(context).size.width / 2) +
        (itemWidth / 2);
    _thumbController.animateTo(
      offset.clamp(0.0, _thumbController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    ref.read(photoViewerProvider.notifier).setIndex(index);
    _scrollThumbnailIntoView(index);
  }

  void _onThumbnailTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onDoubleTap() {
    if (widget.photos.isEmpty) return;

    final viewerState = ref.read(photoViewerProvider);
    final currentIndex =
        viewerState.currentIndex.clamp(0, widget.photos.length - 1).toInt();

    if (viewerState.isZoomed) {
      _transformControllers[currentIndex].value = Matrix4.identity();
      return;
    }

    // Zoom to 2.5x at tap position
    if (_lastTapDownDetails != null) {
      final ctrl = _transformControllers[currentIndex];
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset local =
          box.globalToLocal(_lastTapDownDetails!.globalPosition);
      final Size size = box.size;
      final Offset center = Offset(size.width / 2, size.height / 2);
      final Offset offset = local - center;

      final matrix = Matrix4.identity()
        ..translateByDouble(-offset.dx * 1.5, -offset.dy * 1.5, 0, 1)
        ..scaleByDouble(2.5, 2.5, 2.5, 1);
      ctrl.value = matrix;
    }

    // Trigger like
    final alreadyLiked = ref.read(likeProvider(widget.profileUid));
    if (alreadyLiked) {
      _showAlreadyLikedToast();
      return;
    }

    ref.read(likeProvider(widget.profileUid).notifier).like();
    _heartController.forward(from: 0);
    _showLikeFlash();
  }

  void _showLikeFlash() {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.15, end: 0.0),
            duration: const Duration(milliseconds: 150),
            builder: (context, value, child) {
              return Container(
                  color: SawaLoveTheme.primary.withValues(alpha: value));
            },
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 150), entry.remove);
  }

  void _showAlreadyLikedToast() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.photoViewerAlreadyLiked),
        action: SnackBarAction(
          label: l10n.photoViewerUndo,
          onPressed: () {
            // ref.read(rewindModalProvider.notifier).show();
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onDoubleTapDown(TapDownDetails details, int index) {
    _lastTapDownDetails = details;
  }

  void _onShare() {
    final link = 'sawalove://profile/${widget.profileUid}';
    Clipboard.setData(ClipboardData(text: link));
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.photoViewerLinkCopied)),
    );
  }

  void _onReport() {
    if (widget.photos.isEmpty) return;

    final currentIndex = ref.read(photoViewerProvider).currentIndex;
    final safeIndex = currentIndex.clamp(0, widget.photos.length - 1).toInt();
    final photoUrl = widget.photos[safeIndex].url ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportSheet(
        profileUid: widget.profileUid,
        photoUrl: photoUrl,
        onReasonSelected: (reason) {
          Navigator.of(context).pop();
          final qReason = Uri.encodeQueryComponent(reason);
          final qPhotoUrl = Uri.encodeQueryComponent(photoUrl);
          context.push(
            '/profile/${widget.profileUid}/report?reason=$qReason&photoUrl=$qPhotoUrl',
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbController.dispose();
    _heartController.dispose();
    for (final c in _transformControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewerState = ref.watch(photoViewerProvider);
    final currentIndex = widget.photos.isEmpty
        ? 0
        : viewerState.currentIndex.clamp(0, widget.photos.length - 1).toInt();
    final isZoomed = viewerState.isZoomed;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _restoreSystemUI();
      },
      child: Semantics(
        label:
            'Photo viewer for ${widget.name}. Photo ${currentIndex + 1} of ${widget.photos.length}.',
        child: Scaffold(
          backgroundColor: Colors.black,
          body: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;
              if (isLandscape) {
                return _LandscapeLayout(
                  photos: widget.photos,
                  currentIndex: currentIndex,
                  pageController: _pageController,
                  transformControllers: _transformControllers,
                  isZoomed: isZoomed,
                  onPageChanged: _onPageChanged,
                  onThumbnailTap: _onThumbnailTap,
                  onDoubleTap: _onDoubleTap,
                  onDoubleTapDown: _onDoubleTapDown,
                  name: widget.name,
                  age: widget.age,
                  city: widget.city,
                  badges: widget.badges,
                  heartController: _heartController,
                  onClose: () => context.pop(),
                  onShare: _onShare,
                  onReport: _onReport,
                );
              }

              return _PortraitLayout(
                photos: widget.photos,
                currentIndex: currentIndex,
                pageController: _pageController,
                transformControllers: _transformControllers,
                isZoomed: isZoomed,
                onPageChanged: _onPageChanged,
                onThumbnailTap: _onThumbnailTap,
                onDoubleTap: _onDoubleTap,
                onDoubleTapDown: _onDoubleTapDown,
                name: widget.name,
                age: widget.age,
                city: widget.city,
                badges: widget.badges,
                heartController: _heartController,
                onClose: () => context.pop(),
                onShare: _onShare,
                onReport: _onReport,
                showPinchHint: viewerState.showPinchHint,
                thumbController: _thumbController,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Portrait Layout
// ---------------------------------------------------------------------------

class _PortraitLayout extends StatelessWidget {
  final List<PhotoSlot> photos;
  final int currentIndex;
  final PageController pageController;
  final List<TransformationController> transformControllers;
  final bool isZoomed;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;
  final VoidCallback onDoubleTap;
  final void Function(TapDownDetails, int) onDoubleTapDown;
  final String name;
  final int? age;
  final String? city;
  final List<String>? badges;
  final AnimationController heartController;
  final VoidCallback onClose;
  final VoidCallback onShare;
  final VoidCallback onReport;
  final bool showPinchHint;
  final ScrollController thumbController;

  const _PortraitLayout({
    required this.photos,
    required this.currentIndex,
    required this.pageController,
    required this.transformControllers,
    required this.isZoomed,
    required this.onPageChanged,
    required this.onThumbnailTap,
    required this.onDoubleTap,
    required this.onDoubleTapDown,
    required this.name,
    required this.age,
    required this.city,
    required this.badges,
    required this.heartController,
    required this.onClose,
    required this.onShare,
    required this.onReport,
    required this.showPinchHint,
    required this.thumbController,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return _EmptyPhotoViewer(
        name: name,
        onClose: onClose,
        onShare: onShare,
        onReport: onReport,
      );
    }

    final safeIndex = currentIndex.clamp(0, photos.length - 1).toInt();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo stage
        PageView.builder(
          controller: pageController,
          physics: isZoomed
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(),
          onPageChanged: onPageChanged,
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return GestureDetector(
              onDoubleTapDown: (details) => onDoubleTapDown(details, index),
              onDoubleTap: onDoubleTap,
              child: Semantics(
                label:
                    'Photo ${index + 1}: ${photo.caption ?? "no caption"}. Double tap to like.',
                child: InteractiveViewer(
                  transformationController: transformControllers[index],
                  minScale: 1.0,
                  maxScale: 4.0,
                  clipBehavior: Clip.hardEdge,
                  child: _PhotoImage(photo: photo, fit: BoxFit.contain),
                ),
              ),
            );
          },
        ),

        // Heart animation overlay
        _HeartOverlay(controller: heartController),

        // Top gradient + controls
        _TopGradientOverlay(
          currentIndex: safeIndex,
          total: photos.length,
          onClose: onClose,
          onShare: onShare,
          onReport: onReport,
        ),

        // Bottom gradient + info
        _BottomGradientOverlay(
          name: name,
          age: age,
          city: city,
          caption: photos[safeIndex].caption,
          badges: badges,
        ),

        // Dot indicators
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Semantics(
            label:
                'Photo navigation dots. Currently viewing photo ${safeIndex + 1} of ${photos.length}.',
            excludeSemantics: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (index) {
                final isActive = index == safeIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 16.0 : 6.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isActive ? 3.0 : 3.0),
                  ),
                );
              }),
            ),
          ),
        ),

        // Thumbnail strip
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          height: 52,
          child: Semantics(
            label: 'Photo thumbnails. Tap a thumbnail to navigate.',
            container: true,
            child: ListView.builder(
              controller: thumbController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final isActive = index == safeIndex;
                return GestureDetector(
                  onTap: () => onThumbnailTap(index),
                  child: Container(
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isActive
                            ? SawaLoveTheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child:
                          _PhotoImage(photo: photos[index], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Pinch hint
        if (showPinchHint) const Center(child: _PinchHintPill()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Landscape Layout
// ---------------------------------------------------------------------------

class _LandscapeLayout extends StatelessWidget {
  final List<PhotoSlot> photos;
  final int currentIndex;
  final PageController pageController;
  final List<TransformationController> transformControllers;
  final bool isZoomed;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;
  final VoidCallback onDoubleTap;
  final void Function(TapDownDetails, int) onDoubleTapDown;
  final String name;
  final int? age;
  final String? city;
  final List<String>? badges;
  final AnimationController heartController;
  final VoidCallback onClose;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const _LandscapeLayout({
    required this.photos,
    required this.currentIndex,
    required this.pageController,
    required this.transformControllers,
    required this.isZoomed,
    required this.onPageChanged,
    required this.onThumbnailTap,
    required this.onDoubleTap,
    required this.onDoubleTapDown,
    required this.name,
    required this.age,
    required this.city,
    required this.badges,
    required this.heartController,
    required this.onClose,
    required this.onShare,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return _EmptyPhotoViewer(
        name: name,
        onClose: onClose,
        onShare: onShare,
        onReport: onReport,
      );
    }

    final safeIndex = currentIndex.clamp(0, photos.length - 1).toInt();

    return Row(
      children: [
        // Photo ~65% width
        Expanded(
          flex: 65,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: pageController,
                physics: isZoomed
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                onPageChanged: onPageChanged,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onDoubleTapDown: (details) =>
                        onDoubleTapDown(details, index),
                    onDoubleTap: onDoubleTap,
                    child: InteractiveViewer(
                      transformationController: transformControllers[index],
                      minScale: 1.0,
                      maxScale: 4.0,
                      clipBehavior: Clip.hardEdge,
                      child: _PhotoImage(
                          photo: photos[index], fit: BoxFit.contain),
                    ),
                  );
                },
              ),
              _HeartOverlay(controller: heartController),
              _TopGradientOverlay(
                currentIndex: safeIndex,
                total: photos.length,
                onClose: onClose,
                onShare: onShare,
                onReport: onReport,
              ),
            ],
          ),
        ),
        // Right panel 110dp
        SizedBox(
          width: 110,
          child: ColoredBox(
            color: const Color(0xFF0D0508),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name${age != null ? ', $age' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (city != null)
                          Text(
                            city!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (photos[safeIndex].caption != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              photos[safeIndex].caption!,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (badges != null && badges!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: badges!
                            .map((b) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    b,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 10),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  const Spacer(),
                  // Vertical thumbnail column
                  Expanded(
                    child: ListView.builder(
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final isActive = index == safeIndex;
                        return GestureDetector(
                          onTap: () => onThumbnailTap(index),
                          child: Container(
                            width: 52,
                            height: 52,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isActive
                                    ? SawaLoveTheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: _PhotoImage(
                                  photo: photos[index], fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _PhotoImage extends StatelessWidget {
  final PhotoSlot photo;
  final BoxFit fit;

  const _PhotoImage({
    required this.photo,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final url = photo.url;
    if (url == null || url.isEmpty) {
      return const _MissingPhotoPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => Container(color: Colors.grey.shade900),
      errorWidget: (context, url, error) => const _MissingPhotoPlaceholder(),
    );
  }
}

class _MissingPhotoPlaceholder extends StatelessWidget {
  const _MissingPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child:
          const Icon(Icons.image_not_supported, color: Colors.grey, size: 64),
    );
  }
}

class _EmptyPhotoViewer extends StatelessWidget {
  final String name;
  final VoidCallback onClose;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const _EmptyPhotoViewer({
    required this.name,
    required this.onClose,
    required this.onShare,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _MissingPhotoPlaceholder(),
        _TopGradientOverlay(
          currentIndex: 0,
          total: 0,
          onClose: onClose,
          onShare: onShare,
          onReport: onReport,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '$name has no photos available.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopGradientOverlay extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const _TopGradientOverlay({
    required this.currentIndex,
    required this.total,
    required this.onClose,
    required this.onShare,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
            stops: [0.0, 0.6],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Semantics(
              label: l10n.photoViewerCloseSemantics,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  total == 0 ? '0/0' : '${currentIndex + 1}/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: onShare,
            ),
            Semantics(
              label: l10n.photoViewerReportSemantics,
              button: true,
              child: IconButton(
                icon: const Icon(Icons.flag_outlined, color: Colors.white),
                onPressed: onReport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomGradientOverlay extends StatelessWidget {
  final String name;
  final int? age;
  final String? city;
  final String? caption;
  final List<String>? badges;

  const _BottomGradientOverlay({
    required this.name,
    required this.age,
    required this.city,
    required this.caption,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
            stops: [0.0, 0.7],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$name${age != null ? ', $age' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (city != null)
              Text(
                city!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            if (caption != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  caption!,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (badges != null && badges!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: badges!
                      .map((b) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              b,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeartOverlay extends StatelessWidget {
  final AnimationController controller;

  const _HeartOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            ),
            child: const Icon(
              Icons.favorite,
              color: SawaLoveTheme.primary,
              size: 120,
            ),
          ),
        ),
      ),
    );
  }
}

class _PinchHintPill extends StatelessWidget {
  const _PinchHintPill();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.photoViewerPinchHint,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Report Sheet
// ---------------------------------------------------------------------------

class _ReportSheet extends StatelessWidget {
  final String profileUid;
  final String photoUrl;
  final ValueChanged<String> onReasonSelected;

  const _ReportSheet({
    required this.profileUid,
    required this.photoUrl,
    required this.onReasonSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reasons = <String>[
      l10n.reportReasonInappropriate,
      l10n.reportReasonSpam,
      l10n.reportReasonHarassment,
      l10n.reportReasonUnderage,
      l10n.reportReasonOther,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A0A10),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.reportUserTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: reasons.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        reasons[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: Colors.white54),
                      onTap: () => onReasonSelected(reasons[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
