import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_profile.dart';
import 'glass_card.dart';

class StatsCard extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;

  const StatsCard({super.key, required this.profile, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String, IconData, Color)>[
      ('${profile.rating}', 'driver_detail_rating'.tr(), Iconsax.star_1_copy, const Color(0xFFFFC107)),
      ('${profile.trips}', 'driver_detail_trips'.tr(), Iconsax.route_square_copy, const Color(0xFF3D5AFE)),
      ('${profile.years}', 'driver_detail_years'.tr(), Iconsax.calendar_tick_copy, const Color(0xFF7C4DFF)),
      (profile.responseTime, 'driver_detail_response'.tr(), Iconsax.timer_1_copy, const Color(0xFF4CAF50)),
    ];
    return Padding(
      padding: EdgeInsets.only(top: 48.r),
      child: DriverGlassCard(
        isDark: isDark,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.r, horizontal: 8.r),
          child: Row(
            children: stats.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              return Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.r),
                  decoration: BoxDecoration(
                    border: i < stats.length - 1
                        ? Border(
                            right: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.$3, size: 17.r, color: s.$4),
                      SizedBox(height: 5.r),
                      Text(
                        s.$1,
                        style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w900, color: cs.onSurface),
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        s.$2,
                        style: TextStyle(
                          fontSize: 9.r,
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
