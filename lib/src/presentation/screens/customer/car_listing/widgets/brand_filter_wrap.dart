import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/car_listing_provider.dart';
import 'brand_chip.dart';

/// Wrapping brand filter grid used on desktop.
class BrandFilterWrap extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const BrandFilterWrap({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarListingProvider>();
    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: provider.brands
          .map(
            (b) => BrandChip(
              label: b,
              active: provider.selectedBrand == b,
              isDark: isDark,
              cs: cs,
              onTap: () => provider.selectBrand(b),
            ),
          )
          .toList(),
    );
  }
}
