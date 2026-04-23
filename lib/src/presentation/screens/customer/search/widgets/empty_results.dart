import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EmptyResults extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  const EmptyResults({
    super.key,
    required this.isDark,
    required this.cs,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

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
              color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.search_zoom_out, color: const Color(0xFFE91E63).withValues(alpha: 0.5), size: 36.r),
          ),
          SizedBox(height: 16.r),
          Text(
            'search_no_results'.tr(),
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 6.r),
          Text(
            'search_no_results_subtitle'.tr(),
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.r),
          if (hasActiveFilters)
            GestureDetector(
              onTap: onClearFilters,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 10.r),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'search_clear_filters'.tr(),
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
