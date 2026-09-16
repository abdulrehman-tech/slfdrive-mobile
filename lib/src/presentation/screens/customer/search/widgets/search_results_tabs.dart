import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/app_error_state.dart';
import '../../../../widgets/load_more.dart';
import '../../../../widgets/skeletons/list_skeleton.dart';
import '../../../../widgets/vehicles/vehicle_filter_bar.dart';
import '../../../../widgets/vehicles/vehicle_results_view.dart';
import '../provider/search_provider.dart';
import 'search_driver_card.dart';

/// Cars | Drivers results, each tab paging on its own.
class SearchResultsTabs extends StatelessWidget {
  final double side;

  const SearchResultsTabs({super.key, required this.side});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SearchProvider>();
    final cs = Theme.of(context).colorScheme;
    final carCount = p.cars.isLoading || p.cars.error != null ? null : p.cars.totalCount;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: side),
            child: TabBar(
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurface.withValues(alpha: 0.55),
              indicatorColor: cs.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: cs.onSurface.withValues(alpha: 0.08),
              labelStyle: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700),
              unselectedLabelStyle: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: _label('search_filter_cars'.tr(), carCount)),
                Tab(text: _label('search_filter_drivers'.tr(), p.driverCount)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                VehicleResultsView(
                  catalog: p.cars,
                  onOpen: (v) {
                    p.rememberQuery();
                    context.pushNamed('car-detail', pathParameters: {'id': v.id.toString()});
                  },
                  headerSlivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.r),
                        child: VehicleFilterBar(catalog: p.cars, padding: EdgeInsets.symmetric(horizontal: side)),
                      ),
                    ),
                  ],
                ),
                _DriverResults(side: side),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _label(String name, int? count) => count == null ? name : '$name · $count';
}

class _DriverResults extends StatelessWidget {
  final double side;

  const _DriverResults({required this.side});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SearchProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drivers = p.drivers;

    final Widget body;
    if (p.driversLoading || p.driversStillPaging) {
      body = const SliverFillRemaining(child: ListSkeleton(itemCount: 5, itemHeight: 74));
    } else if (p.driversError != null) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorState(message: p.driversError, onRetry: p.retryDrivers, isDark: isDark),
      );
    } else if (drivers.isEmpty) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.r, 48.r, 24.r, 24.r),
          child: Column(
            children: [
              Icon(Iconsax.profile_2user_copy, size: 40.r, color: cs.primary.withValues(alpha: 0.6)),
              SizedBox(height: 12.r),
              Text(
                'search_no_results'.tr(),
                style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
              SizedBox(height: 6.r),
              Text(
                'search_no_results_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    } else {
      body = SliverPadding(
        padding: EdgeInsets.fromLTRB(side, 12.r, side, 0),
        sliver: SliverList.separated(
          itemCount: drivers.length,
          separatorBuilder: (_, _) => SizedBox(height: 10.r),
          itemBuilder: (_, i) => SearchDriverCard(
            driver: drivers[i],
            isDark: isDark,
            cs: cs,
            onTap: () {
              p.rememberQuery();
              context.pushNamed('driver-detail', pathParameters: {'id': drivers[i].id});
            },
          ),
        ),
      );
    }

    return LoadMoreListener(
      enabled: p.canLoadMoreDrivers,
      onLoadMore: p.loadMoreDrivers,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          body,
          if (!p.driversLoading && p.driversError == null && drivers.isNotEmpty)
            SliverToBoxAdapter(
              child: LoadMoreFooter(
                isLoading: p.driversLoadingMore,
                failed: p.driversLoadMoreFailed,
                onRetry: p.retryMoreDrivers,
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 32.r + MediaQuery.of(context).padding.bottom)),
        ],
      ),
    );
  }
}
