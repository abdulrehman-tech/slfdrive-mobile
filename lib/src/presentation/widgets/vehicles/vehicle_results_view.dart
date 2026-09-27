import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/models/vehicle/vehicle.dart';
import '../../providers/vehicle_catalog.dart';
import '../app_error_state.dart';
import '../load_more.dart';
import '../skeletons/list_skeleton.dart';
import 'vehicle_card.dart';

/// Scrollable, lazily paged results of a [VehicleCatalog] below
/// [headerSlivers]: a list on phones, a grid on wider screens, with loading,
/// error, empty (with "Clear filters") and next-page states.
class VehicleResultsView extends StatelessWidget {
  final VehicleCatalog catalog;
  final List<Widget> headerSlivers;
  final ValueChanged<Vehicle> onOpen;

  /// Content column cap on wide screens.
  static const double maxContentWidth = 1100;

  const VehicleResultsView({super.key, required this.catalog, required this.onOpen, this.headerSlivers = const []});

  /// Side padding that centres a [maxContentWidth] column.
  static double sidePadding(double width) => math.max(16.r, (width - maxContentWidth) / 2);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: catalog,
      builder: (context, _) {
        final showFooter = !catalog.isLoading && catalog.error == null && catalog.vehicles.isNotEmpty;
        return LoadMoreListener(
          enabled: catalog.canLoadMore,
          onLoadMore: catalog.loadMore,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              ...headerSlivers,
              _body(context),
              if (showFooter)
                SliverToBoxAdapter(
                  child: LoadMoreFooter(
                    isLoading: catalog.isLoadingMore,
                    failed: catalog.loadMoreFailed,
                    onRetry: catalog.retryLoadMore,
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 32.r + MediaQuery.of(context).padding.bottom)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (catalog.isLoading || !catalog.started) {
      return SliverFillRemaining(child: ListSkeleton(itemCount: 5, itemHeight: VehicleCard.height));
    }
    if (catalog.error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorState(message: catalog.error, onRetry: catalog.reload, isDark: isDark),
      );
    }
    if (catalog.vehicles.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: _EmptyResults(catalog: catalog));
    }
    final vehicles = catalog.vehicles;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final side = sidePadding(width);
        Widget card(int i) => RepaintBoundary(
              child: VehicleCard(
                vehicle: vehicles[i],
                rating: catalog.ratingFor(vehicles[i]),
                ar: catalog.ar,
                onTap: () => onOpen(vehicles[i]),
              ),
            );
        return SliverPadding(
          padding: EdgeInsets.fromLTRB(side, 4.r, side, 0),
          sliver: width - 2 * side >= 680
              ? SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 520,
                    mainAxisExtent: VehicleCard.extentOf(context),
                    crossAxisSpacing: 14.r,
                    mainAxisSpacing: 14.r,
                  ),
                  delegate: SliverChildBuilderDelegate((_, i) => card(i), childCount: vehicles.length),
                )
              : SliverList.separated(
                  itemCount: vehicles.length,
                  itemBuilder: (_, i) => card(i),
                  separatorBuilder: (_, _) => SizedBox(height: 12.r),
                ),
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final VehicleCatalog catalog;

  const _EmptyResults({required this.catalog});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = !catalog.query.isEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.r, 48.r, 24.r, 24.r),
      child: Column(
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(Iconsax.car_copy, size: 32.r, color: cs.primary.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 14.r),
          Text(
            'car_listing_empty'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          SizedBox(height: 6.r),
          Text(
            (filtered ? 'search_no_results_subtitle' : 'car_listing_empty_subtitle').tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
          if (catalog.query.hasFilters) ...[
            SizedBox(height: 16.r),
            OutlinedButton.icon(
              onPressed: () => catalog.setQuery(catalog.query.withoutFilters()),
              style: OutlinedButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13.r),
              ),
              icon: Icon(Iconsax.filter_remove_copy, size: 16.r),
              label: Text('search_clear_filters'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}
