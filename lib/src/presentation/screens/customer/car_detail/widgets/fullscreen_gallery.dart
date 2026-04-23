import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'image_dots.dart';

/// Fullscreen image gallery with swipe, hero transition, pinch and double-tap zoom.
class FullscreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late final PageController _controller;
  late int _current;
  final Map<int, TransformationController> _transformControllers = {};

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final c in _transformControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TransformationController _controllerFor(int i) =>
      _transformControllers.putIfAbsent(i, () => TransformationController());

  void _handleDoubleTap(int i) {
    final tc = _controllerFor(i);
    if (tc.value != Matrix4.identity()) {
      tc.value = Matrix4.identity();
    } else {
      tc.value = Matrix4.identity()..scaleByDouble(2.5, 2.5, 2.5, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) {
              for (final c in _transformControllers.values) {
                c.value = Matrix4.identity();
              }
              setState(() => _current = i);
            },
            itemBuilder: (_, i) {
              return GestureDetector(
                onDoubleTap: () => _handleDoubleTap(i),
                child: InteractiveViewer(
                  transformationController: _controllerFor(i),
                  minScale: 1,
                  maxScale: 5,
                  clipBehavior: Clip.none,
                  child: Center(
                    child: Hero(
                      tag: 'car-image-$i',
                      child: CachedNetworkImage(
                        imageUrl: widget.images[i],
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const Center(
                          child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
                        ),
                        errorWidget: (_, _, _) => Icon(
                          Iconsax.car_copy,
                          size: 80.r,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.r,
            left: 16.r,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Icon(CupertinoIcons.xmark, color: Colors.white, size: 20.r),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 14.r,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${_current + 1} / ${widget.images.length}',
                  style: TextStyle(color: Colors.white, fontSize: 13.r, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24.r,
            left: 0,
            right: 0,
            child: ImageDots(count: widget.images.length, active: _current, activeWidth: 22),
          ),
        ],
      ),
    );
  }
}

/// Pushes [FullscreenGallery] with a fade transition, starting at [initialIndex].
void openFullscreenGallery(
  BuildContext context, {
  required List<String> images,
  required int initialIndex,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => FullscreenGallery(
        images: images,
        initialIndex: initialIndex,
      ),
      transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
    ),
  );
}
