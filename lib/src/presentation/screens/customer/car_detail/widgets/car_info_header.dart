import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../data/car_detail_mock_data.dart';
import 'car_glass_card.dart';

/// Header card showing car name, availability, brand chip, rating and price.
class CarInfoHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const CarInfoHeader({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kCarDetailName,
                    style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'car_status_available'.tr(),
                    style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.r),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    kCarDetailBrand,
                    style: TextStyle(fontSize: 10.r, color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(width: 10.r),
                Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 14.r),
                SizedBox(width: 4.r),
                Text(
                  kCarDetailRating,
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(width: 4.r),
                Text(
                  kCarDetailReviewsLabel,
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.45)),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OmrIcon(size: 16.r, color: cs.primary),
                    SizedBox(width: 3.r),
                    Text(
                      kCarDetailPricePerDayLabel,
                      style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.primary),
                    ),
                    Text(
                      'car_detail_per_day'.tr(),
                      style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Iconsax.location, size: 14.r, color: cs.onSurface.withValues(alpha: 0.4)),
                SizedBox(width: 4.r),
                Text(
                  kCarDetailLocation,
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
