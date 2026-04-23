import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/home_provider.dart';
import 'driver_card.dart';
import 'section_header.dart';

class NearbyDriversSection extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  const NearbyDriversSection({super.key, this.isDesktop = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final drivers = context.watch<HomeProvider>().nearbyDrivers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'home_nearby_drivers'.tr(),
          cs: cs,
          onViewAll: () => context.pushNamed('driver-listing'),
          isDesktop: isDesktop,
        ),
        if (isDesktop)
          ...drivers.map(
            (d) => Padding(
              padding: EdgeInsets.only(bottom: 12.r),
              child: DriverCard(
                driver: d,
                isDark: isDark,
                cs: cs,
                horizontal: true,
                onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': d.id}),
              ),
            ),
          )
        else
          SizedBox(
            height: 168.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              itemCount: drivers.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsetsDirectional.only(end: 12.r),
                child: DriverCard(
                  driver: drivers[i],
                  isDark: isDark,
                  cs: cs,
                  onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': drivers[i].id}),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
