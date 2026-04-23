import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_profile.dart';
import 'glass_card.dart';
import 'section_header.dart';

class ServicesCard extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;

  const ServicesCard({super.key, required this.profile, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return DriverGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DriverSectionHeader(
              cs: cs,
              icon: Iconsax.medal_star_copy,
              color: const Color(0xFF00BCD4),
              title: 'driver_detail_services'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            GridView.count(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8.r,
              mainAxisSpacing: 8.r,
              childAspectRatio: 1.2,
              children: profile.services.map((e) {
                return Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: e.$3.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(e.$1, size: 20.r, color: e.$3),
                      SizedBox(height: 6.r),
                      Text(
                        e.$2.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: cs.onSurface),
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
