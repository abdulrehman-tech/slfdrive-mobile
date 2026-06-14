import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../favorites/provider/favorites_provider.dart';
import '../provider/car_detail_provider.dart';
import 'car_glass_button.dart';
import 'fullscreen_gallery.dart';
import 'image_dots.dart';

/// Swipeable image gallery used on desktop (and optionally standalone mobile).
///
/// Exposes an overlay with back + favourite glass buttons when [isDesktop] is
/// false. On desktop the gallery is embedded in a rounded card, no overlay.
class ImageGallery extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final bool isDesktop;

  const ImageGallery({
    super.key,
    required this.isDark,
    required this.cs,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarDetailProvider>();
    final images = provider.images;
    final height = isDesktop ? 340.r : 280.r;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: isDesktop ? BorderRadius.circular(20.r) : BorderRadius.zero,
          child: SizedBox(
            height: height,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: provider.setImageIndex,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => openFullscreenGallery(context, images: images, initialIndex: i),
                child: Hero(
                  tag: 'car-image-$i',
                  child: CachedNetworkImage(
                    imageUrl: images[i],
                    width: double.infinity,
                    height: height,
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
          ),
        ),
        if (!isDesktop)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.r,
            left: 16.r,
            right: 16.r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CarGlassButton(
                  icon: CupertinoIcons.back,
                  isDark: isDark,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Builder(
                  builder: (context) {
                    final fav = context.watch<FavoritesProvider>();
                    final id = provider.vehicle?.id.toString();
                    final isFav = id != null && fav.isCarFav(id);
                    return CarGlassButton(
                      icon: isFav ? Iconsax.heart : Iconsax.heart_copy,
                      isDark: isDark,
                      onTap: () {
                        final snap = provider.favSnapshot();
                        if (snap != null) fav.toggleCar(snap);
                      },
                      iconColor: isFav ? const Color(0xFFE91E63) : null,
                    );
                  },
                ),
              ],
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
