import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'models/car_item.dart';
import 'provider/car_listing_provider.dart';
import 'widgets/brand_filter_list.dart';
import 'widgets/brand_filter_wrap.dart';
import 'widgets/car_list_card.dart';
import 'widgets/car_listing_app_bar.dart';
import 'widgets/circle_icon_button.dart';
import 'widgets/desktop_sort_button.dart';
import 'widgets/empty_state.dart';
import 'widgets/results_count.dart';
import 'widgets/sort_bottom_sheet.dart';

// ============================================================
// CAR LISTING SCREEN
// ============================================================

class CarListingScreen extends StatelessWidget {
  final String? initialBrand;
  const CarListingScreen({super.key, this.initialBrand});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarListingProvider(initialBrand: initialBrand),
      child: const _CarListingView(),
    );
  }
}

class _CarListingView extends StatelessWidget {
  const _CarListingView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  void _navigateToDetail(BuildContext context, CarItem car) {
    context.pushNamed('car-detail', pathParameters: {'id': car.id});
  }

  void _showSortSheet(BuildContext context, bool isDark, ColorScheme cs) {
    final provider = context.read<CarListingProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SortBottomSheet(
        isDark: isDark,
        cs: cs,
        current: provider.sortBy,
        onSelect: (v) {
          provider.setSort(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _isDark(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktop(context, isDark, cs) : _buildMobile(context, isDark, cs),
    );
  }

  // ==========================================================================
  // MOBILE LAYOUT
  // ==========================================================================

  Widget _buildMobile(BuildContext context, bool isDark, ColorScheme cs) {
    final cars = context.watch<CarListingProvider>().filteredCars;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CarListingAppBar(
          isDark: isDark,
          cs: cs,
          onSortTap: () => _showSortSheet(context, isDark, cs),
        ),
        SliverToBoxAdapter(child: BrandFilterList(isDark: isDark, cs: cs)),
        SliverToBoxAdapter(child: SizedBox(height: 12.r)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: ResultsCount(count: cars.length, cs: cs),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.r)),
        if (cars.isEmpty)
          SliverFillRemaining(child: EmptyState(isDark: isDark, cs: cs))
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.only(bottom: 14.r),
                  child: CarListCard(
                    car: cars[i],
                    isDark: isDark,
                    cs: cs,
                    onTap: () => _navigateToDetail(context, cars[i]),
                  ),
                ),
                childCount: cars.length,
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 40.r)),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT
  // ==========================================================================

  Widget _buildDesktop(BuildContext context, bool isDark, ColorScheme cs) {
    final cars = context.watch<CarListingProvider>().filteredCars;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: CupertinoIcons.back,
                    onTap: () => Navigator.of(context).pop(),
                    isDark: isDark,
                    cs: cs,
                  ),
                  SizedBox(width: 12.r),
                  Text(
                    'car_listing_title'.tr(),
                    style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                  const Spacer(),
                  DesktopSortButton(
                    isDark: isDark,
                    cs: cs,
                    onTap: () => _showSortSheet(context, isDark, cs),
                  ),
                ],
              ),
              SizedBox(height: 20.r),
              BrandFilterWrap(isDark: isDark, cs: cs),
              SizedBox(height: 16.r),
              ResultsCount(count: cars.length, cs: cs),
              SizedBox(height: 16.r),
              if (cars.isEmpty)
                SizedBox(height: 300.r, child: EmptyState(isDark: isDark, cs: cs))
              else
                Wrap(
                  spacing: 16.r,
                  runSpacing: 16.r,
                  children: cars
                      .map(
                        (c) => SizedBox(
                          width: 340.r,
                          child: CarListCard(
                            car: c,
                            isDark: isDark,
                            cs: cs,
                            onTap: () => _navigateToDetail(context, c),
                          ),
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }
}
