import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/charts/revenue_bar_chart.dart';
import '../provider/driver_home_provider.dart';

class EarningsCard extends StatelessWidget {
  final bool isDark;

  const EarningsCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverHomeProvider>();
    final earnings = provider.todayEarnings;
    final bars = provider.weekly
        .map((d) => RevenueBar(
              label: d.labelKey.tr(),
              value: d.amount,
              highlighted: d.isToday,
            ))
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4D63DD).withValues(alpha: 0.3), blurRadius: 20.r, offset: Offset(0, 8.r)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'driver_today_earnings'.tr(),
              style: TextStyle(fontSize: 14.r, color: Colors.white.withValues(alpha: 0.8)),
            ),
            SizedBox(height: 12.r),
            Text(
              'OMR ${earnings.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 32.r, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20.r),
            if (bars.isNotEmpty)
              RevenueBarChart(
                bars: bars,
                barColor: Colors.white,
                trackColor: Colors.white.withValues(alpha: 0.3),
                labelColor: Colors.white.withValues(alpha: 0.7),
                highlightLabelColor: Colors.white,
                maxBarHeight: 44.r,
              ),
          ],
        ),
      ),
    );
  }
}
