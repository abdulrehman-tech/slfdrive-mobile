import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/car_detail_provider.dart';
import 'fullscreen_gallery.dart';
import 'image_dots.dart';

/// Image gallery rendered inside a [SliverAppBar.flexibleSpace] on mobile.
class SliverImageGallery extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const SliverImageGallery({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarDetailProvider>();
    final images = provider.images;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: provider.setImageIndex,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => openFullscreenGallery(context, images: images, initialIndex: i),
            child: Hero(
              tag: 'car-image-$i',
              child: CachedNetworkImage(
                imageUrl: images[i],
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                ),
                errorWidget: (_, _, _) => Container(
                  color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                  child: Center(
                    child: Icon(Iconsax.car_copy, size: 40.r, color: cs.primary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 50.r,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12.r,
          left: 0,
          right: 0,
          child: ImageDots(count: images.length, active: provider.currentImageIndex),
        ),
      ],
    );
  }
}
