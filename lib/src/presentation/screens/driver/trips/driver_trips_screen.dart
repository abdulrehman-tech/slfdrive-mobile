import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'provider/driver_trips_provider.dart';
import 'widgets/driver_trips_empty_state.dart';
import 'widgets/driver_trips_list.dart';
import 'widgets/driver_trips_tab_selector.dart';

class DriverTripsScreen extends StatelessWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverTripsProvider(),
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
                'driver_trips'.tr(),
                style: TextStyle(
                  fontSize: 20.r,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(80.r),
                child: DriverTripsTabSelector(isDark: isDark),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.r)),
            SliverToBoxAdapter(
              child: trips.isEmpty
                  ? DriverTripsEmptyState(
                      title: DriverTripsProvider.emptyTitles[tabIndex].tr(),
                      subtitle: DriverTripsProvider.emptySubs[tabIndex].tr(),
                      isDark: isDark,
                    )
                  : DriverTripsList(trips: trips, isDark: isDark),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }
}
