import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'car_glass_card.dart';
import 'section_header.dart';

/// Card with the car description copy.
class DescriptionSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const DescriptionSection({super.key, required this.isDark, required this.cs});

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
              icon: Iconsax.document_text,
              accent: const Color(0xFF00BCD4),
              title: 'car_detail_description'.tr(),
              isDark: isDark,
              cs: cs,
            ),
            SizedBox(height: 10.r),
            Text(
              'car_detail_description_placeholder'.tr(),
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
