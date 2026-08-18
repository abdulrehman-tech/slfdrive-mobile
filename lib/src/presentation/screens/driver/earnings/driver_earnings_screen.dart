import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../widgets/app_error_state.dart';
import '../shell/driver_shell_provider.dart';
import 'provider/driver_earnings_provider.dart';
import 'widgets/earnings_chart_card.dart';
import 'widgets/earnings_period_selector.dart';
import 'widgets/earnings_skeleton.dart';
import 'widgets/earnings_stats_grid.dart';
import 'widgets/earnings_total_card.dart';
import 'widgets/recent_earnings_section.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Derives from the shared shell (provided by the driver shell above this
    // tab body) — no fetch of its own.
    return ChangeNotifierProvider(
      create: (ctx) => DriverEarningsProvider(ctx.read<DriverShellProvider>()),
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
    final showSkeleton = provider.isInitialLoading;
    final showError = !showSkeleton && provider.error != null && !provider.hasData;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DriverEarningsProvider>().load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
              if (showSkeleton)
                const SliverToBoxAdapter(child: EarningsSkeleton())
              else if (showError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorState(
                    message: provider.error,
                    onRetry: provider.load,
                    isDark: isDark,
                  ),
                )
              else ...[
                // A refresh that fails with data on screen keeps the numbers
                // and explains itself in a banner instead of failing silently.
                if (provider.error != null)
                  SliverToBoxAdapter(
                    child: _EarningsErrorBanner(isDark: isDark),
                  ),
                SliverToBoxAdapter(
                  child: EarningsTotalCard(snapshot: snapshot, trendPercent: provider.trendPercent),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 20.r)),
                SliverToBoxAdapter(
                  child: EarningsChartCard(isDark: isDark),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsErrorBanner extends StatelessWidget {
  final bool isDark;

  const _EarningsErrorBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverEarningsProvider>();
    return Container(
      margin: EdgeInsets.fromLTRB(20.r, 0, 20.r, 12.r),
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 18.r, color: const Color(0xFFE53935)),
          SizedBox(width: 10.r),
          Expanded(
            child: Text(
              provider.error?.tr() ?? 'error_occurred'.tr(),
              style: TextStyle(fontSize: 12.r, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          TextButton(
            onPressed: provider.load,
            child: Text('retry'.tr(), style: TextStyle(fontSize: 12.r)),
          ),
        ],
      ),
    );
  }
}
