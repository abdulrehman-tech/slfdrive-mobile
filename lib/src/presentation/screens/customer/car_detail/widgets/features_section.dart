import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../data/car_detail_mock_data.dart';
import 'car_glass_card.dart';
import 'section_header.dart';

/// Wrap of feature chips (GPS, Bluetooth, etc).
class FeaturesSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const FeaturesSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final features = buildCarFeatures();

    return CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Iconsax.magic_star,
              accent: const Color(0xFF7C4DFF),
              title: 'car_detail_features'.tr(),
              isDark: isDark,
              cs: cs,
            ),
            SizedBox(height: 12.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: features.map((f) => _FeatureChip(label: f, isDark: isDark, cs: cs)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final ColorScheme cs;

  const _FeatureChip({required this.label, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.tick_circle, size: 12.r, color: const Color(0xFF4CAF50)),
          SizedBox(width: 5.r),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.r,
              color: cs.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
