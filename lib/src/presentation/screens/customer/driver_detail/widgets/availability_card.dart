import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_profile.dart';
import 'glass_card.dart';
import 'section_header.dart';

class AvailabilityCard extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;

  const AvailabilityCard({super.key, required this.profile, required this.isDark, required this.cs});

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
              icon: Iconsax.calendar_2_copy,
              color: const Color(0xFF4CAF50),
              title: 'driver_detail_availability'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            Row(
              children: profile.availability.map((day) {
                final available = day.$2;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.r),
                    child: Column(
                      children: [
                        Text(
                          day.$1,
                          style: TextStyle(
                            fontSize: 10.r,
                            color: cs.onSurface.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6.r),
                        Container(
                          width: double.infinity,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: available
                                ? const Color(0xFF4CAF50).withValues(alpha: isDark ? 0.25 : 0.15)
                                : const Color(0xFFE53935).withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Icon(
                              available ? Iconsax.tick_circle_copy : Iconsax.close_circle_copy,
                              size: 14.r,
                              color: available ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ],
                    ),
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
