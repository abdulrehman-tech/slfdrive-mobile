import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../data/car_detail_mock_data.dart';
import '../models/car_spec.dart';
import 'car_glass_card.dart';
import 'section_header.dart';

/// Grid of car specs (seats, transmission, fuel, etc).
class SpecsSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const SpecsSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final specs = buildCarSpecs();

    return CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Iconsax.cpu_setting,
              accent: const Color(0xFF3D5AFE),
              title: 'car_detail_specs'.tr(),
              isDark: isDark,
              cs: cs,
            ),
            GridView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.r),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.r,
                mainAxisSpacing: 12.r,
                childAspectRatio: 1.5,
              ),
              itemCount: specs.length,
              itemBuilder: (context, index) => _SpecTile(spec: specs[index], isDark: isDark, cs: cs),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final CarSpec spec;
  final bool isDark;
  final ColorScheme cs;

  const _SpecTile({required this.spec, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.r, horizontal: 10.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: spec.color.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(spec.icon, size: 16.r, color: spec.color),
          ),
          SizedBox(height: 8.r),
          Text(
            spec.value,
            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.r),
          Text(
            spec.label,
            style: TextStyle(
              fontSize: 10.r,
              color: cs.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
