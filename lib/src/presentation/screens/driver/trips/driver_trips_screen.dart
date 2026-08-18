import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../widgets/app_error_state.dart';
import '../../../widgets/skeletons/list_skeleton.dart';
import '../shell/driver_shell_provider.dart';
import 'models/driver_trip.dart';
import 'provider/driver_trips_provider.dart';
import 'widgets/driver_trips_empty_state.dart';
import 'widgets/driver_trips_list.dart';
import 'widgets/driver_trips_tab_selector.dart';

class DriverTripsScreen extends StatelessWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Derives from the shared shell (provided by the driver shell above this
    // tab body) — no fetch of its own.
    return ChangeNotifierProvider(
      create: (ctx) => DriverTripsProvider(ctx.read<DriverShellProvider>()),
      child: const _DriverTripsView(),
    );
  }
}

class _DriverTripsView extends StatelessWidget {
  const _DriverTripsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<DriverTripsProvider>();
    final trips = provider.filteredTrips;
    final tabIndex = provider.tabIndex;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DriverTripsProvider>().load(),
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
                  'driver_trips'.tr(),
                  style: TextStyle(
                    fontSize: 20.r,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(100.r),
                  child: DriverTripsTabSelector(isDark: isDark),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20.r)),
              // A refresh that fails while trips are on screen keeps the list
              // and surfaces the problem in a slim banner instead of hiding it.
              if (provider.error != null && provider.trips.isNotEmpty)
                SliverToBoxAdapter(child: _ErrorBanner(isDark: isDark)),
              SliverToBoxAdapter(
                child: _buildContent(context, provider, trips, tabIndex, isDark),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100.r)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DriverTripsProvider provider,
    List<DriverTrip> trips,
    int tabIndex,
    bool isDark,
  ) {
    // Skeleton only before the first data arrives — post-action refreshes keep
    // the rendered list on screen.
    if (provider.isInitialLoading) {
      return const ListSkeleton(itemCount: 4, itemHeight: 120);
    }
    if (provider.error != null && provider.trips.isEmpty) {
      return AppErrorState(message: provider.error, onRetry: provider.load, isDark: isDark);
    }
    if (trips.isEmpty) {
      return DriverTripsEmptyState(
        title: DriverTripsProvider.emptyTitles[tabIndex].tr(),
        subtitle: DriverTripsProvider.emptySubs[tabIndex].tr(),
        isDark: isDark,
      );
    }
    return DriverTripsList(trips: trips, isDark: isDark);
  }
}

class _ErrorBanner extends StatelessWidget {
  final bool isDark;

  const _ErrorBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverTripsProvider>();
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
