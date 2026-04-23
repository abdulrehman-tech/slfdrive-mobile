import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'provider/favorites_provider.dart';
import 'widgets/drivers_section_header.dart';
import 'widgets/empty_favorites.dart';
import 'widgets/fav_car_card.dart';
import 'widgets/fav_driver_card.dart';
import 'widgets/favorites_app_bar.dart';
import 'widgets/favorites_filter_chips.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesProvider(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode ||
        (tp.isSystemMode &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _isDark(context);
    return isDesktop ? _buildDesktop(context, isDark) : _buildMobile(context, isDark);
  }

  // ==========================================================================
  // MOBILE
  // ==========================================================================

  Widget _buildMobile(BuildContext context, bool isDark) {
    final provider = context.watch<FavoritesProvider>();
    final showCars = provider.showCars;
    final showDrivers = provider.showDrivers;
    final cars = provider.cars;
    final drivers = provider.drivers;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        FavoritesAppBar(isDark: isDark),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 8.r),
            child: FavoritesFilterChips(isDark: isDark),
          ),
        ),
        if (provider.isEmpty)
          SliverFillRemaining(child: EmptyFavorites(isDark: isDark))
        else ...[
          if (showCars && cars.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: 14.r),
                    child: FavCarCard(
                      car: cars[i],
                      isDark: isDark,
                      onRemove: () =>
                          context.read<FavoritesProvider>().removeCarAt(i),
                      onTap: () => context.pushNamed(
                        'car-detail',
                        pathParameters: {'id': cars[i].id},
                      ),
                    ),
                  ),
                  childCount: cars.length,
                ),
              ),
            ),
          if (showDrivers && drivers.isNotEmpty) ...[
            if (showCars && cars.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 12.r),
                  child: DriversSectionHeader(isDark: isDark),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: 12.r),
                    child: FavDriverCard(
                      driver: drivers[i],
                      isDark: isDark,
                      onRemove: () =>
                          context.read<FavoritesProvider>().removeDriverAt(i),
                      onTap: () => context.pushNamed(
                        'driver-detail',
                        pathParameters: {'id': drivers[i].id},
                      ),
                    ),
                  ),
                  childCount: drivers.length,
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 100.r)),
        ],
      ],
    );
  }

  // ==========================================================================
  // DESKTOP
  // ==========================================================================

  Widget _buildDesktop(BuildContext context, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<FavoritesProvider>();
    final showCars = provider.showCars;
    final showDrivers = provider.showDrivers;
    final cars = provider.cars;
    final drivers = provider.drivers;

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
                  Text(
                    'favorites_title'.tr(),
                    style: TextStyle(
                      fontSize: 24.r,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(width: 24.r),
                  Expanded(child: FavoritesFilterChips(isDark: isDark)),
                ],
              ),
              SizedBox(height: 24.r),
              if (provider.isEmpty)
                SizedBox(
                  height: 400.r,
                  child: EmptyFavorites(isDark: isDark),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showCars)
                      Expanded(
                        flex: 3,
                        child: Wrap(
                          spacing: 16.r,
                          runSpacing: 16.r,
                          children: cars.asMap().entries.map((e) {
                            return SizedBox(
                              width: 320.r,
                              child: FavCarCard(
                                car: e.value,
                                isDark: isDark,
                                onRemove: () => context
                                    .read<FavoritesProvider>()
                                    .removeCarAt(e.key),
                                onTap: () => context.pushNamed(
                                  'car-detail',
                                  pathParameters: {'id': e.value.id},
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    if (showCars && showDrivers && drivers.isNotEmpty)
                      SizedBox(width: 24.r),
                    if (showDrivers && drivers.isNotEmpty)
                      SizedBox(
                        width: 300.r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DriversSectionHeader(isDark: isDark),
                            SizedBox(height: 12.r),
                            ...drivers.asMap().entries.map((e) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.r),
                                child: FavDriverCard(
                                  driver: e.value,
                                  isDark: isDark,
                                  onRemove: () => context
                                      .read<FavoritesProvider>()
                                      .removeDriverAt(e.key),
                                  onTap: () => context.pushNamed(
                                    'driver-detail',
                                    pathParameters: {'id': e.value.id},
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }
}
