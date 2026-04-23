import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'circle_icon_button.dart';

/// Frosted sliver app bar for the mobile car listing view.
class CarListingAppBar extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onSortTap;

  const CarListingAppBar({
    super.key,
    required this.isDark,
    required this.cs,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      toolbarHeight: 64.r,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 12.r),
        child: Center(
          child: CircleIconButton(
            icon: CupertinoIcons.back,
            onTap: () => Navigator.of(context).pop(),
            isDark: isDark,
            cs: cs,
          ),
        ),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.72),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'car_listing_title'.tr(),
        style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
      ),
      actions: [
        Padding(
          padding: EdgeInsetsDirectional.only(end: 16.r),
          child: GestureDetector(
            onTap: onSortTap,
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
                ),
              ),
              child: Icon(Iconsax.sort, color: cs.onSurface.withValues(alpha: 0.6), size: 18.r),
            ),
          ),
        ),
      ],
    );
  }
}
