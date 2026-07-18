import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/charts/revenue_bar_chart.dart';
import '../provider/driver_earnings_provider.dart';

/// White card housing the period revenue bar chart on the earnings screen.
class EarningsChartCard extends StatelessWidget {
  final bool isDark;

  const EarningsChartCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverEarningsProvider>();
    final bars = provider.chartData
        .map((c) => RevenueBar(
              label: c.label,
              value: c.value,
              highlighted: c.highlight,
            ))
        .toList();

    if (bars.isEmpty) return const SizedBox.shrink();

    const accent = Color(0xFF4D63DD);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.r),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'earnings_revenue'.tr(),
              style: TextStyle(
                fontSize: 15.r,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 20.r),
            RevenueBarChart(
              bars: bars,
              barColor: accent,
              trackColor: accent.withValues(alpha: isDark ? 0.25 : 0.15),
              labelColor: isDark ? Colors.white54 : const Color(0xFF9E9E9E),
              highlightLabelColor: isDark ? Colors.white : accent,
              maxBarHeight: 90.r,
            ),
          ],
        ),
      ),
    );
  }
}
