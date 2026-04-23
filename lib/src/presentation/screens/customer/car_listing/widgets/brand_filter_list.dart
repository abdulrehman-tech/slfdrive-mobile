import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/car_listing_provider.dart';
import 'brand_chip.dart';

/// Horizontally scrolling brand filter row used on mobile.
class BrandFilterList extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const BrandFilterList({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarListingProvider>();
    final brands = provider.brands;
    return Container(
      margin: EdgeInsets.only(top: 12.r),
      child: SizedBox(
        height: 44.r,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.r),
          itemCount: brands.length,
          itemBuilder: (_, i) {
            final brand = brands[i];
            return Padding(
              padding: EdgeInsetsDirectional.only(end: 8.r),
              child: BrandChip(
                label: brand,
                active: provider.selectedBrand == brand,
                isDark: isDark,
                cs: cs,
                onTap: () => provider.selectBrand(brand),
              ),
            );
          },
        ),
      ),
    );
  }
}
