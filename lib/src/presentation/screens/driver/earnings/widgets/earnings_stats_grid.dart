import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/earnings_period.dart';
import 'earnings_stat_card.dart';

class EarningsStatsGrid extends StatelessWidget {
  final EarningsSnapshot snapshot;
  final bool isDark;

  const EarningsStatsGrid({
    super.key,
    required this.snapshot,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: EarningsStatCard(
                  icon: Iconsax.car,
                  label: 'earnings_trips'.tr(),
                  value: snapshot.trips.toString(),
                  color: const Color(0xFF4D63DD),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: EarningsStatCard(
                  icon: Iconsax.clock,
                  label: 'earnings_hours'.tr(),
                  value: snapshot.hours.toString(),
                  color: const Color(0xFFFFA000),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.r),
          EarningsStatCard(
            icon: Iconsax.chart,
            label: 'earnings_avg_trip'.tr(),
            value: 'OMR ${snapshot.avgPerTrip.toStringAsFixed(2)}',
            color: const Color(0xFF4CAF50),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
