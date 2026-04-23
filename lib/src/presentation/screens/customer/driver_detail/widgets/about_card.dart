import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_profile.dart';
import 'glass_card.dart';
import 'section_header.dart';

class AboutCard extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;

  const AboutCard({super.key, required this.profile, required this.isDark, required this.cs});

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
              icon: Iconsax.info_circle_copy,
              color: const Color(0xFF3D5AFE),
              title: 'driver_detail_about'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 10.r),
            Text(
              profile.bio,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.65), height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}
