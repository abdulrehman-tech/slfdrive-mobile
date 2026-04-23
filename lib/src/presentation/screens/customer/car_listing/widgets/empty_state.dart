import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Centered empty state displayed when no cars match the filter.
class EmptyState extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const EmptyState({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.car, color: cs.primary.withValues(alpha: 0.5), size: 36.r),
          ),
          SizedBox(height: 16.r),
          Text(
            'car_listing_empty'.tr(),
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 6.r),
          Text(
            'car_listing_empty_subtitle'.tr(),
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
