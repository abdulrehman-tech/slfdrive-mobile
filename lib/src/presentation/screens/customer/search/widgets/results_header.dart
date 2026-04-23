import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ResultsHeader extends StatelessWidget {
  final ColorScheme cs;
  final int count;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  const ResultsHeader({
    super.key,
    required this.cs,
    required this.count,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$count ${'search_results'.tr()}',
          style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        const Spacer(),
        if (hasActiveFilters)
          GestureDetector(
            onTap: onClearFilters,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.close_circle, size: 14.r, color: const Color(0xFFE91E63)),
                SizedBox(width: 4.r),
                Text(
                  'search_clear_filters'.tr(),
                  style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w600, color: const Color(0xFFE91E63)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final String title;
  final IconData icon;
  final Color color;

  const SectionLabel({
    super.key,
    required this.isDark,
    required this.cs,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26.r,
          height: 26.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Icon(icon, color: color, size: 13.r),
        ),
        SizedBox(width: 8.r),
        Text(
          title,
          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ],
    );
  }
}
