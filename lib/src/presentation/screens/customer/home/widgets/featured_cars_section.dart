import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/home_provider.dart';
import 'car_card.dart';
import 'section_header.dart';

class FeaturedCarsSection extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  const FeaturedCarsSection({super.key, this.isDesktop = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final home = context.watch<HomeProvider>();
    final cars = home.cars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'home_all_collections'.tr(),
          cs: cs,
          onViewAll: () => context.pushNamed('car-listing'),
          isDesktop: isDesktop,
        ),
        if (isDesktop)
          ...List.generate(
            cars.length,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 16.r),
              child: CarCard(
                car: cars[i],
                isDark: isDark,
                cs: cs,
                onFavourite: () => home.toggleFavourite(cars[i].id),
                onTap: () => context.pushNamed('car-detail', pathParameters: {'id': cars[i].id}),
              ),
            ),
          )
        else
          SizedBox(
            height: 270.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              itemCount: cars.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsetsDirectional.only(end: 16.r),
                child: SizedBox(
                  width: 220.r,
                  child: CarCard(
                    car: cars[i],
                    isDark: isDark,
                    cs: cs,
                    onFavourite: () => home.toggleFavourite(cars[i].id),
                    onTap: () => context.pushNamed('car-detail', pathParameters: {'id': cars[i].id}),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
