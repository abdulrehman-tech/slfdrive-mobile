import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'models/driver_item.dart';
import 'provider/driver_listing_provider.dart';
import 'widgets/desktop_header.dart';
import 'widgets/driver_list_card.dart';
import 'widgets/empty_state.dart';
import 'widgets/listing_app_bar.dart';
import 'widgets/results_count_label.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'widgets/speciality_chip_bar.dart';
import 'widgets/speciality_chip_wrap.dart';

class DriverListingScreen extends StatelessWidget {
  final String? initialFilter;
  const DriverListingScreen({super.key, this.initialFilter});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverListingProvider(initialFilter: initialFilter),
      child: const _DriverListingView(),
    );
  }
}

class _DriverListingView extends StatelessWidget {
  const _DriverListingView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  void _navigateToDetail(BuildContext context, DriverItem driver) {
    context.pushNamed('driver-detail', pathParameters: {'id': driver.id});
  }

  void _showSortSheet(BuildContext context, bool isDark, ColorScheme cs) {
    final provider = context.read<DriverListingProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SortBottomSheet(
        isDark: isDark,
        cs: cs,
        current: provider.sortBy,
        onSelect: (v) {
          provider.setSortBy(v);
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

  Widget _buildMobile(BuildContext context, bool isDark, ColorScheme cs) {
    final provider = context.watch<DriverListingProvider>();
    final drivers = provider.filteredDrivers;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        ListingAppBar(
          isDark: isDark,
          cs: cs,
          onSortTap: () => _showSortSheet(context, isDark, cs),
        ),
        SliverToBoxAdapter(
          child: SpecialityChipBar(
            specialities: provider.specialities,
            selected: provider.selectedSpeciality,
            isDark: isDark,
            cs: cs,
            onSelect: provider.selectSpeciality,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.r)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: ResultsCountLabel(count: drivers.length, cs: cs),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.r)),
        if (drivers.isEmpty)
          SliverFillRemaining(child: EmptyState(isDark: isDark, cs: cs))
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.only(bottom: 12.r),
                  child: DriverListCard(
                    driver: drivers[i],
                    isDark: isDark,
                    cs: cs,
                    onTap: () => _navigateToDetail(context, drivers[i]),
                  ),
                ),
                childCount: drivers.length,
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 40.r)),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, bool isDark, ColorScheme cs) {
    final provider = context.watch<DriverListingProvider>();
    final drivers = provider.filteredDrivers;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DesktopHeader(
                isDark: isDark,
                cs: cs,
                onSortTap: () => _showSortSheet(context, isDark, cs),
              ),
              SizedBox(height: 20.r),
              SpecialityChipWrap(
                specialities: provider.specialities,
                selected: provider.selectedSpeciality,
                isDark: isDark,
                cs: cs,
                onSelect: provider.selectSpeciality,
              ),
              SizedBox(height: 16.r),
              ResultsCountLabel(count: drivers.length, cs: cs),
              SizedBox(height: 16.r),
              if (drivers.isEmpty)
                SizedBox(height: 300.r, child: EmptyState(isDark: isDark, cs: cs))
              else
                Wrap(
                  spacing: 16.r,
                  runSpacing: 16.r,
                  children: drivers
                      .map(
                        (d) => SizedBox(
                          width: 340.r,
                          child: DriverListCard(
                            driver: d,
                            isDark: isDark,
                            cs: cs,
                            onTap: () => _navigateToDetail(context, d),
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
