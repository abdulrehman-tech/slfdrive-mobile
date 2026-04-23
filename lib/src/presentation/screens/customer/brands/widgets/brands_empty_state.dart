import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BrandsEmptyState extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const BrandsEmptyState({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.08),
            ),
            child: Icon(Iconsax.search_normal_copy, size: 32.r, color: cs.primary.withValues(alpha: 0.6)),
          ),
          SizedBox(height: 14.r),
          Text(
            'brands_empty_title'.tr(),
            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          SizedBox(height: 4.r),
          Text(
            'brands_empty_subtitle'.tr(),
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
