import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/skeletons/list_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../core/di/injection_container.dart';
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
  // [initialFilter] is accepted for router compatibility but unused — the API
  // has no speciality filter. The UI offers an "All / Has Vehicle" toggle instead.
  // ignore: unused_element
  final String? initialFilter;

  const DriverListingScreen({super.key, this.initialFilter});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverListingProvider(
        repository: getIt<DriverListingRepository>(),
        ar: context.locale.languageCode == 'ar',
      ),
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

  /// Maps filter chips to [DriverVehicleFilter].
  ///
  /// We reuse the existing chip widgets which operate on plain [String] labels.
  /// The two labels are looked up from localization; filter selection converts
  /// back to the enum at the provider boundary.
  static List<String> _filterLabels(BuildContext context) => [
        'driver_listing_filter_all'.tr(),
        'driver_filter_has_vehicle'.tr(),
      ];

  String _selectedLabel(BuildContext context, DriverVehicleFilter filter) {
    final labels = _filterLabels(context);
    return filter == DriverVehicleFilter.hasVehicle ? labels[1] : labels[0];
  }

  void _onChipSelect(DriverListingProvider provider, String label, BuildContext context) {
    final labels = _filterLabels(context);
    final filter = label == labels[1] ? DriverVehicleFilter.hasVehicle : DriverVehicleFilter.all;
    provider.selectVehicleFilter(filter);
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
    final filterLabels = _filterLabels(context);
    final selectedLabel = _selectedLabel(context, provider.vehicleFilter);

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
            specialities: filterLabels,
            selected: selectedLabel,
            isDark: isDark,
            cs: cs,
            onSelect: (label) => _onChipSelect(provider, label, context),
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
        if (provider.isLoading)
          SliverFillRemaining(
            child: const ListSkeleton(itemCount: 5, itemHeight: 96),
          )
        else if (provider.error != null)
          SliverFillRemaining(
            child: _ErrorRetry(message: provider.error!, cs: cs, onRetry: provider.refresh),
          )
        else if (drivers.isEmpty)
          SliverFillRemaining(child: EmptyState(isDark: isDark, cs: cs))
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.r),
                    child: DriverListCard(
                      driver: drivers[i],
                      isDark: isDark,
                      cs: cs,
                      onTap: () => _navigateToDetail(context, drivers[i]),
                    ),
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
    final filterLabels = _filterLabels(context);
    final selectedLabel = _selectedLabel(context, provider.vehicleFilter);

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
                specialities: filterLabels,
                selected: selectedLabel,
                isDark: isDark,
                cs: cs,
                onSelect: (label) => _onChipSelect(provider, label, context),
              ),
              SizedBox(height: 16.r),
              ResultsCountLabel(count: drivers.length, cs: cs),
              SizedBox(height: 16.r),
              if (provider.isLoading)
                SizedBox(
                  height: 300.r,
                  child: const ListSkeleton(itemCount: 5, itemHeight: 96),
                )
              else if (provider.error != null)
                SizedBox(
                  height: 300.r,
                  child: _ErrorRetry(message: provider.error!, cs: cs, onRetry: provider.refresh),
                )
              else if (drivers.isEmpty)
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

/// Centered error message with a retry button.
class _ErrorRetry extends StatelessWidget {
  final String message;
  final ColorScheme cs;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.cs, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 40.r,
              color: cs.primary.withValues(alpha: 0.6),
            ),
            SizedBox(height: 12.r),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.7)),
            ),
            SizedBox(height: 16.r),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: cs.primary),
              child: Text('common_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
