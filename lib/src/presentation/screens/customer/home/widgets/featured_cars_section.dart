import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/auth_gate.dart';
import '../../favorites/models/fav_car.dart';
import '../../favorites/provider/favorites_provider.dart';
import '../models/car_item.dart';
import '../provider/home_provider.dart';
import 'car_card.dart';
import 'section_header.dart';

class FeaturedCarsSection extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  const FeaturedCarsSection({super.key, this.isDesktop = false, required this.isDark});

  // Saving a favourite is a gated action — guests are prompted to log in.
  Future<void> _onFavourite(BuildContext context, FavoritesProvider fav, CarItem car) async {
    if (!await requireLogin(context)) return;
    fav.toggleCar(FavCar(
      id: car.id,
      name: car.name,
      imageUrl: car.imageUrl,
      pricePerDay: car.pricePerDay,
      brand: '',
      rating: car.rating ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final home = context.watch<HomeProvider>();
    final fav = context.watch<FavoritesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'home_all_collections'.tr(),
          cs: cs,
          onViewAll: () => context.pushNamed('car-listing'),
          isDesktop: isDesktop,
        ),
        if (home.carsLoading)
          _SectionSpinner(isDark: isDark)
        else if (home.carsError != null)
          _SectionError(
            message: home.carsError!,
            isDark: isDark,
            cs: cs,
            onRetry: home.load,
          )
        else if (home.featuredCars.isEmpty)
          _SectionEmpty(label: 'home_no_cars'.tr(), isDark: isDark, cs: cs)
        else if (isDesktop)
          ...List.generate(
            home.featuredCars.length,
            (i) {
              final car = home.featuredCars[i]..isFavourite = fav.isCarFav(home.featuredCars[i].id);
              return Padding(
                padding: EdgeInsets.only(bottom: 16.r),
                child: CarCard(
                  car: car,
                  isDark: isDark,
                  cs: cs,
                  onFavourite: () => _onFavourite(context, fav, car),
                  onTap: () => context.pushNamed('car-detail', pathParameters: {'id': car.id}),
                ),
              );
            },
          )
        else
          SizedBox(
            height: 270.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              itemCount: home.featuredCars.length,
              itemBuilder: (_, i) {
                final car = home.featuredCars[i]..isFavourite = fav.isCarFav(home.featuredCars[i].id);
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: 16.r),
                  child: SizedBox(
                    width: 220.r,
                    child: CarCard(
                      car: car,
                      isDark: isDark,
                      cs: cs,
                      onFavourite: () => _onFavourite(context, fav, car),
                      onTap: () => context.pushNamed('car-detail', pathParameters: {'id': car.id}),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Shared section-level state widgets ─────────────────────────────────────

class _SectionSpinner extends StatelessWidget {
  final bool isDark;
  const _SectionSpinner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.r,
      child: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  final String message;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onRetry;

  const _SectionError({
    required this.message,
    required this.isDark,
    required this.cs,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.r,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2_copy, color: cs.error, size: 22.r),
          SizedBox(height: 6.r),
          Text(
            message,
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.r),
          TextButton(
            onPressed: onRetry,
            child: Text('retry'.tr(), style: TextStyle(fontSize: 12.r, color: cs.primary)),
          ),
        ],
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  final String label;
  final bool isDark;
  final ColorScheme cs;

  const _SectionEmpty({required this.label, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.r,
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.45)),
        ),
      ),
    );
  }
}
