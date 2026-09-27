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
import '../shell/widgets/driver_sliver_header.dart';

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

    return RefreshIndicator(
      onRefresh: () => context.read<DriverTripsProvider>().load(),
      // Spinner appears below the pinned header, not behind it.
      edgeOffset: DriverSliverHeader.expandedExtent(context, bottomHeight: DriverTripsTabSelector.height),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Large title that collapses into a compact one; the selector stays
          // pinned underneath and the bar turns to glass over the content.
          DriverSliverHeader(
            title: 'driver_trips'.tr(),
            isDark: isDark,
            bottom: DriverTripsTabSelector(isDark: isDark),
            bottomHeight: DriverTripsTabSelector.height,
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8.r)),
          // A refresh that fails while trips are on screen keeps the list
          // and surfaces the problem in a slim banner instead of hiding it.
          if (provider.error != null && provider.trips.isNotEmpty)
            SliverToBoxAdapter(child: _ErrorBanner(isDark: isDark)),
          SliverToBoxAdapter(
            child: _buildContent(context, provider, trips, tabIndex, isDark),
          ),
          SliverToBoxAdapter(child: SizedBox(height: driverBottomClearance(context))),
        ],
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
