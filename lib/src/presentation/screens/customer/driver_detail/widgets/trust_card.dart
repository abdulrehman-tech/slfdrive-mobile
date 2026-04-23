import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'glass_card.dart';
import 'section_header.dart';

class TrustCard extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const TrustCard({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, Color)>[
      (Iconsax.tick_circle_copy, 'driver_trust_background', const Color(0xFF4CAF50)),
      (Iconsax.shield_tick_copy, 'driver_trust_insured', const Color(0xFF3D5AFE)),
      (Iconsax.personalcard_copy, 'driver_trust_licensed', const Color(0xFF7C4DFF)),
      (Iconsax.heart_add_copy, 'driver_trust_safety', const Color(0xFFE91E63)),
    ];
    return DriverGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DriverSectionHeader(
              cs: cs,
              icon: Iconsax.security_safe_copy,
              color: const Color(0xFF4CAF50),
              title: 'driver_detail_trust'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            GridView.count(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8.r,
              mainAxisSpacing: 8.r,
              childAspectRatio: 2.8,
              children: items.map((e) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: e.$3.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(e.$1, size: 14.r, color: e.$3),
                      SizedBox(width: 6.r),
                      Expanded(
                        child: Text(
                          e.$2.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
