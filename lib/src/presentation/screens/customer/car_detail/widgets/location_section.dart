import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../data/car_detail_mock_data.dart';
import 'car_glass_card.dart';
import 'section_header.dart';

/// Card showing the car pickup location (map placeholder for now).
class LocationSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const LocationSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Iconsax.location,
              accent: const Color(0xFFE91E63),
              title: 'car_detail_location'.tr(),
              isDark: isDark,
              cs: cs,
            ),
            SizedBox(height: 12.r),
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                height: 140.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.map, size: 28.r, color: cs.onSurface.withValues(alpha: 0.2)),
                      SizedBox(height: 6.r),
                      Text(
                        kCarDetailLocation,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
