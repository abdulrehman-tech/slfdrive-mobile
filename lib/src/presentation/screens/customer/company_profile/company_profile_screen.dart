import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/company/company_profile.dart';
import '../../../widgets/app_error_state.dart';
import '../../../widgets/skeletons/list_skeleton.dart';
import '../../../widgets/vehicles/vehicle_card.dart';
import '../driver_detail/models/driver_review.dart';
import '../driver_detail/widgets/review_tile.dart';
import '../driver_listing/models/driver_item.dart';
import '../driver_listing/widgets/driver_list_card.dart';
import 'company_profile_provider.dart';
import 'widgets/company_about_card.dart';
import 'widgets/company_header.dart';
import 'widgets/company_overview.dart';

/// Public profile of a rental company (`AllCompanies/{id}/profile`): header
/// with logo and stats, contact details, and its vehicles, drivers and reviews.
/// Reached from the company name/logo on cars, drivers and bookings.
class CompanyProfileScreen extends StatelessWidget {
  final int companyId;
  const CompanyProfileScreen({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyProfileProvider(companyId: companyId),
      child: const _CompanyProfileView(),
    );
  }
}

class _CompanyProfileView extends StatelessWidget {
  const _CompanyProfileView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyProfileProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = provider.profile;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    if (profile == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(backgroundColor: bg, elevation: 0),
        body: provider.isLoading
            ? const ListSkeleton(itemCount: 4, itemHeight: 140)
            : AppErrorState(message: provider.error, onRetry: provider.load, isDark: isDark),
      );
    }

    final ar = context.locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        onRefresh: provider.load,
        edgeOffset: MediaQuery.paddingOf(context).top + kToolbarHeight,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            CompanyHeader(profile: profile, ar: ar),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 4.r),
              sliver: SliverList.list(
                children: [
                  CompanyStatsCard(profile: profile, isDark: isDark),
                  SizedBox(height: 12.r),
                  CompanyActions(company: profile.company, isDark: isDark),
                  SizedBox(height: 12.r),
                  CompanyAboutCard(company: profile.company, isDark: isDark),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabsDelegate(profile: profile, tab: provider.tab, isDark: isDark, bg: bg, onTab: provider.setTab),
            ),
            ..._tabContent(context, provider, profile, ar, isDark),
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24.r)),
          ],
        ),
      ),
    );
  }

  List<Widget> _tabContent(
    BuildContext context,
    CompanyProfileProvider provider,
    CompanyProfile profile,
    bool ar,
    bool isDark,
  ) {
    final cs = Theme.of(context).colorScheme;
    Widget empty(IconData icon, String key) => SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48.r, horizontal: 32.r),
            child: Column(
              children: [
                Icon(icon, size: 40.r, color: cs.onSurface.withValues(alpha: 0.25)),
                SizedBox(height: 12.r),
                Text(key.tr(), textAlign: TextAlign.center, style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
        );
    Widget list(int count, Widget Function(int) item) => SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.r),
          sliver: SliverList.separated(
            itemCount: count,
            separatorBuilder: (_, _) => SizedBox(height: 12.r),
            itemBuilder: (_, i) => item(i),
          ),
        );

    switch (provider.tab) {
      case CompanyTab.vehicles:
        if (profile.vehicles.isEmpty) return [empty(Iconsax.car, 'company_no_vehicles')];
        return [
          list(profile.vehicles.length, (i) {
            final v = profile.vehicles[i];
            return SizedBox(
              height: VehicleCard.extentOf(context),
              child: VehicleCard(
                vehicle: v,
                ar: ar,
                rating: provider.ratings.vehicleAverage(v.id),
                showCompany: false,
                onTap: () => context.pushNamed('car-detail', pathParameters: {'id': '${v.id}'}),
              ),
            );
          }),
        ];
      case CompanyTab.drivers:
        if (profile.drivers.isEmpty) return [empty(Iconsax.profile_2user, 'company_no_drivers')];
        return [
          list(profile.drivers.length, (i) {
            final d = profile.drivers[i];
            final item = DriverItem.fromDriver(d, ar: ar, rating: provider.ratings.driverAverage(d.driverId));
            return DriverListCard(
              driver: item,
              isDark: isDark,
              cs: cs,
              onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': item.id}),
            );
          }),
        ];
      case CompanyTab.reviews:
        if (profile.recentReviews.isEmpty) return [empty(Iconsax.star, 'company_no_reviews')];
        return [
          list(
            profile.recentReviews.length,
            (i) => Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05), blurRadius: 12.r, offset: Offset(0, 4.r)),
                ],
              ),
              // index 0: the tile's own inter-item gap isn't wanted inside a card.
              child: ReviewTile(review: DriverReview.fromReview(profile.recentReviews[i]), index: 0, cs: cs, isDark: isDark),
            ),
          ),
        ];
    }
  }
}

/// Pinned segmented selector: Vehicles / Drivers / Reviews, with counts.
class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final CompanyProfile profile;
  final CompanyTab tab;
  final bool isDark;
  final Color bg;
  final ValueChanged<CompanyTab> onTab;

  _TabsDelegate({required this.profile, required this.tab, required this.isDark, required this.bg, required this.onTab});

  double get _h => 64.r;

  @override
  double get maxExtent => _h;
  @override
  double get minExtent => _h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final tabs = <(CompanyTab, String, int)>[
      (CompanyTab.vehicles, 'company_tab_vehicles', profile.vehicles.length),
      (CompanyTab.drivers, 'company_tab_drivers', profile.drivers.length),
      (CompanyTab.reviews, 'company_tab_reviews', profile.recentReviews.length),
    ];
    final cs = Theme.of(context).colorScheme;
    // The pinned header hands its child loose constraints; the bar must fill
    // the full extent or the sliver's layout and paint extents disagree.
    return Container(
      height: _h,
      color: bg,
      padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 8.r),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFEDEEF2),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            for (final (t, key, count) in tabs)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTab(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 6.r),
                    decoration: BoxDecoration(
                      color: tab == t ? (isDark ? const Color(0xFF34395A) : Colors.white) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: tab == t
                          ? [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 6.r, offset: Offset(0, 2.r))]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            key.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.r,
                              fontWeight: tab == t ? FontWeight.w700 : FontWeight.w500,
                              color: tab == t ? cs.onSurface : cs.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                        SizedBox(width: 5.r),
                        Container(
                          constraints: BoxConstraints(minWidth: 18.r),
                          padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 1.r),
                          decoration: BoxDecoration(
                            color: tab == t ? cs.primary : cs.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.r,
                              fontWeight: FontWeight.w800,
                              color: tab == t ? Colors.white : cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabsDelegate old) =>
      old.tab != tab || old.profile != profile || old.isDark != isDark || old.bg != bg;
}
