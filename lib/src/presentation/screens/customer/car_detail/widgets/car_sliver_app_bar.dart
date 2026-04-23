import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../data/car_detail_mock_data.dart';
import '../provider/car_detail_provider.dart';
import 'sliver_image_gallery.dart';

/// Pinned `SliverAppBar` with the image gallery as `flexibleSpace`, and
/// back / favourite action buttons in the collapsed toolbar.
class CarSliverAppBar extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const CarSliverAppBar({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarDetailProvider>();

    return SliverAppBar(
      pinned: true,
      expandedHeight: 300.r,
      toolbarHeight: 56.r,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF0C2485),
      surfaceTintColor: Colors.transparent,
      title: Text(
        kCarDetailName,
        style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(CupertinoIcons.back, size: 18.r, color: Colors.white),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: provider.toggleFavourite,
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: 12.r),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                provider.isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                size: 18.r,
                color: provider.isFavourite ? const Color(0xFFE91E63) : Colors.white,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(background: SliverImageGallery(isDark: isDark, cs: cs)),
    );
  }
}
