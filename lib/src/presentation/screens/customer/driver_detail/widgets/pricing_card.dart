import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/driver_profile.dart';
import 'glass_card.dart';
import 'section_header.dart';

class PricingCard extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;

  const PricingCard({super.key, required this.profile, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final tiers = <(String, double, String)>[
      ('driver_price_hourly', profile.hourlyRate, 'hr'),
      ('driver_price_daily', profile.dailyRate, 'day'),
      ('driver_price_weekly', profile.weeklyRate, 'wk'),
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
              icon: Iconsax.money_recive_copy,
              color: const Color(0xFF4CAF50),
              title: 'driver_detail_pricing'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            Row(
              children: tiers.asMap().entries.map((e) {
                final i = e.key;
                final t = e.value;
                return Expanded(
                  child: Container(
                    margin: EdgeInsetsDirectional.only(end: i < tiers.length - 1 ? 8.r : 0),
                    padding: EdgeInsets.symmetric(vertical: 12.r, horizontal: 8.r),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          t.$1.tr(),
                          style: TextStyle(
                            fontSize: 10.r,
                            color: cs.onSurface.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6.r),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OmrIcon(size: 11.r, color: cs.primary),
                            SizedBox(width: 2.r),
                            Text(
                              t.$2.toStringAsFixed(0),
                              style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w900, color: cs.primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.r),
                        Text(
                          '/${t.$3}',
                          style: TextStyle(fontSize: 9.r, color: cs.onSurface.withValues(alpha: 0.4)),
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
