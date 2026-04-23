import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DesktopHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onSortTap;

  const DesktopHeader({super.key, required this.isDark, required this.cs, required this.onSortTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
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
            child: Icon(CupertinoIcons.back, color: cs.onSurface, size: 18.r),
          ),
        ),
        SizedBox(width: 12.r),
        Text(
          'driver_listing_title'.tr(),
          style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSortTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.sort, size: 16.r, color: cs.onSurface.withValues(alpha: 0.6)),
                SizedBox(width: 6.r),
                Text(
                  'common_sort'.tr(),
                  style: TextStyle(
                    fontSize: 12.r,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
