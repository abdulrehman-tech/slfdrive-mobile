import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/earnings_period.dart';
import '../../shell/widgets/driver_stat_tile.dart';

class EarningsStatsGrid extends StatelessWidget {
  final EarningsSnapshot snapshot;
  final bool isDark;

  const EarningsStatsGrid({
    super.key,
    required this.snapshot,
    required this.isDark,
  });

  /// "144" rather than "144.0"; keeps one decimal only when there is one.
  static String _hours(double h) => h == h.roundToDouble() ? h.toInt().toString() : h.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    // Three equal tiles in one row, matching the home quick stats (was a
    // 2 + 1 grid with a lone full-width card).
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      // IntrinsicHeight + stretch: equal-height tiles even when one label wraps.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DriverStatTile(
                icon: Iconsax.car,
                value: snapshot.trips.toString(),
                label: 'earnings_trips'.tr(),
                color: const Color(0xFF4D63DD),
                isDark: isDark,
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: DriverStatTile(
                icon: Iconsax.clock,
                value: _hours(snapshot.hours),
                label: 'earnings_booked_hours'.tr(),
                color: const Color(0xFFFFA000),
                isDark: isDark,
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: DriverStatTile(
                icon: Iconsax.chart,
                value: snapshot.avgPerTrip.toStringAsFixed(2),
                label: 'earnings_avg_trip'.tr(),
                color: const Color(0xFF4CAF50),
                isDark: isDark,
                isCurrency: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
