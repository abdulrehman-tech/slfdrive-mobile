import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_profile.dart';
import 'glass_card.dart';
import 'section_header.dart';

class VehiclesCard extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;

  const VehiclesCard({super.key, required this.profile, required this.isDark, required this.cs});

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
              icon: Iconsax.car_copy,
              color: const Color(0xFF7C4DFF),
              title: 'driver_detail_vehicles'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 10.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: profile.vehicles.map((v) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
                  decoration: BoxDecoration(
                    color: v.$3.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: v.$3.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(v.$1, size: 14.r, color: v.$3),
                      SizedBox(width: 6.r),
                      Text(
                        v.$2,
                        style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: v.$3),
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
