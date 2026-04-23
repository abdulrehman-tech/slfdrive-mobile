import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'provider/search_provider.dart';
import 'widgets/empty_results.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/initial_state.dart';
import 'widgets/results_header.dart';
import 'widgets/search_app_bar.dart';
import 'widgets/search_car_card.dart';
import 'widgets/search_driver_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = SearchProvider();
        WidgetsBinding.instance.addPostFrameCallback((_) => p.focusNode.requestFocus());
        return p;
      },
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  void _showFilterSheet(BuildContext context, bool isDark, ColorScheme cs) {
    final provider = context.read<SearchProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FilterBottomSheet(
        isDark: isDark,
        cs: cs,
        typeFilter: provider.typeFilter,
        durationFilter: provider.durationFilter,
        priceRange: provider.priceRange,
        selectedBrands: Set.from(provider.selectedBrands),
        minRating: provider.minRating,
        onApply: (type, duration, price, brands, rating) {
          provider.applyFilters(
            type: type,
            duration: duration,
            price: price,
            brands: brands,
            rating: rating,
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final cs = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.desktop;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A0A14), const Color(0xFF12122A)]
                : [const Color(0xFFF5F7FA), const Color(0xFFE8EDF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isDesktop ? _buildDesktop(context, isDark, cs) : _buildMobile(context, isDark, cs),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context, bool isDark, ColorScheme cs) {
    final provider = context.watch<SearchProvider>();
    final cars = provider.filteredCars;
    final drivers = provider.filteredDrivers;
    final hasResults = cars.isNotEmpty || drivers.isNotEmpty;

    return Column(
      children: [
        SearchAppBar(
          isDark: isDark,
          cs: cs,
          onFilterTap: () => _showFilterSheet(context, isDark, cs),
        ),
        Expanded(
          child: !hasResults
              ? EmptyResults(
                  isDark: isDark,
                  cs: cs,
                  hasActiveFilters: provider.hasActiveFilters,
                  onClearFilters: provider.resetFilters,
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 0),
                      sliver: SliverToBoxAdapter(
                        child: ResultsHeader(
                          cs: cs,
                          count: cars.length + drivers.length,
                          hasActiveFilters: provider.hasActiveFilters,
                          onClearFilters: provider.resetFilters,
                        ),
                      ),
                    ),
                    if (cars.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: EdgeInsets.only(bottom: 12.r),
                              child: SearchCarCard(
                                car: cars[i],
                                isDark: isDark,
                                cs: cs,
                                onTap: () => context.pushNamed('car-detail', pathParameters: {'id': cars[i].id}),
                              ),
                            ),
                            childCount: cars.length,
                          ),
                        ),
                      ),
                    if (drivers.isNotEmpty && cars.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 12.r),
                          child: SectionLabel(
                            isDark: isDark,
                            cs: cs,
                            title: 'search_drivers_section'.tr(),
                            icon: Iconsax.profile_2user_copy,
                            color: const Color(0xFF00BCD4),
                          ),
                        ),
                      ),
                    if (drivers.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: EdgeInsets.only(bottom: 12.r),
                              child: SearchDriverCard(
                                driver: drivers[i],
                                isDark: isDark,
                                cs: cs,
                                onTap: () =>
                                    context.pushNamed('driver-detail', pathParameters: {'id': drivers[i].id}),
                              ),
                            ),
                            childCount: drivers.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: SizedBox(height: 40.r)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, bool isDark, ColorScheme cs) {
    final provider = context.watch<SearchProvider>();
    final cars = provider.filteredCars;
    final drivers = provider.filteredDrivers;
    final hasResults = cars.isNotEmpty || drivers.isNotEmpty;

    return Column(
      children: [
        SearchAppBar(
          isDark: isDark,
          cs: cs,
          onFilterTap: () => _showFilterSheet(context, isDark, cs),
        ),
        Expanded(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1100.r),
              padding: EdgeInsets.symmetric(horizontal: 24.r),
              child: provider.query.isEmpty && !provider.hasActiveFilters
                  ? InitialState(isDark: isDark, cs: cs)
                  : !hasResults
                      ? EmptyResults(
                          isDark: isDark,
                          cs: cs,
                          hasActiveFilters: provider.hasActiveFilters,
                          onClearFilters: provider.resetFilters,
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (provider.typeFilter != 2)
                              Expanded(
                                flex: 3,
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.only(top: 16.r, bottom: 40.r),
                                  children: [
                                    ResultsHeader(
                                      cs: cs,
                                      count: cars.length + drivers.length,
                                      hasActiveFilters: provider.hasActiveFilters,
                                      onClearFilters: provider.resetFilters,
                                    ),
                                    SizedBox(height: 12.r),
                                    Wrap(
                                      spacing: 16.r,
                                      runSpacing: 16.r,
                                      children: cars
                                          .map(
                                            (c) => SizedBox(
                                              width: 340.r,
                                              child: SearchCarCard(
                                                car: c,
                                                isDark: isDark,
                                                cs: cs,
                                                onTap: () =>
                                                    context.pushNamed('car-detail', pathParameters: {'id': c.id}),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            if (provider.typeFilter == 0 && cars.isNotEmpty && drivers.isNotEmpty)
                              SizedBox(width: 24.r),
                            if (provider.typeFilter != 1 && drivers.isNotEmpty)
                              SizedBox(
                                width: 300.r,
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.only(top: 16.r, bottom: 40.r),
                                  children: [
                                    SectionLabel(
                                      isDark: isDark,
                                      cs: cs,
                                      title: 'search_drivers_section'.tr(),
                                      icon: Iconsax.profile_2user_copy,
                                      color: const Color(0xFF00BCD4),
                                    ),
                                    SizedBox(height: 12.r),
                                    ...drivers.map(
                                      (d) => Padding(
                                        padding: EdgeInsets.only(bottom: 12.r),
                                        child: SearchDriverCard(
                                          driver: d,
                                          isDark: isDark,
                                          cs: cs,
                                          onTap: () =>
                                              context.pushNamed('driver-detail', pathParameters: {'id': d.id}),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
            ),
          ),
        ),
      ],
    );
  }
}
