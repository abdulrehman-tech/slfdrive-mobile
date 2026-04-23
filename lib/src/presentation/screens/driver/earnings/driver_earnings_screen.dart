import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'provider/driver_earnings_provider.dart';
import 'widgets/earnings_period_selector.dart';
import 'widgets/earnings_stats_grid.dart';
import 'widgets/earnings_total_card.dart';
import 'widgets/recent_earnings_section.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverEarningsProvider(),
      child: const _DriverEarningsView(),
    );
  }
}

class _DriverEarningsView extends StatelessWidget {
  const _DriverEarningsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<DriverEarningsProvider>();
    final snapshot = provider.snapshot;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              elevation: 0,
              leadingWidth: 56.r,
              titleSpacing: 0,
              title: Text(
                'driver_earnings'.tr(),
                style: TextStyle(
                  fontSize: 20.r,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(72.r),
                child: EarningsPeriodSelector(isDark: isDark),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.r)),
            SliverToBoxAdapter(
              child: EarningsTotalCard(snapshot: snapshot),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.r)),
            SliverToBoxAdapter(
              child: EarningsStatsGrid(snapshot: snapshot, isDark: isDark),
            ),
            SliverToBoxAdapter(
              child: RecentEarningsSection(
                earnings: provider.recentEarnings,
                isDark: isDark,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }
}
