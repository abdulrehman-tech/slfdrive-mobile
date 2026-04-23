import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DrawerStats extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color borderCol;

  const DrawerStats({super.key, required this.isDark, required this.cardBg, required this.borderCol});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stats = [
      (Iconsax.car_copy, '0', 'drawer_trips', const Color(0xFF3D5AFE)),
      (Iconsax.heart_copy, '0', 'drawer_saved', const Color(0xFFE91E63)),
      (Iconsax.star_1_copy, '—', 'drawer_rating', const Color(0xFFFFC107)),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 4.r),
            ),
          ],
        ),
        child: Row(
          children: stats.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.r),
                decoration: BoxDecoration(
                  border: i < stats.length - 1 ? Border(right: BorderSide(color: borderCol)) : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.$1, color: s.$4, size: 18.r),
                    SizedBox(height: 4.r),
                    Text(
                      s.$2,
                      style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      s.$3.tr(),
                      style: TextStyle(
                        fontSize: 9.r,
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
