import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/omr_icon.dart';
import '../provider/car_detail_provider.dart';
import 'car_glass_card.dart';

/// Header card showing car name, availability, brand chip, rating and price.
class CarInfoHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const CarInfoHeader({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarDetailProvider>();
    final vehicle = provider.vehicle;
    if (vehicle == null) return const SizedBox.shrink();

    final ar = provider.ar;
    final title = vehicle.displayTitle(ar: ar);
    final brandLabel = (ar ? vehicle.brandNameAr : vehicle.brandName) ?? vehicle.brandName ?? '';
    final locationLabel = (ar ? vehicle.locationNameAr : vehicle.locationName) ?? vehicle.locationName ?? '';
    final rating = vehicle.rating;
    final price = vehicle.pricePerDay;

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
                    title,
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
                if (brandLabel.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      brandLabel,
                      style: TextStyle(fontSize: 10.r, color: cs.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(width: 10.r),
                ],
                if (rating != null) ...[
                  Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 14.r),
                  SizedBox(width: 4.r),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                ] else
                  Text(
                    'listing_new'.tr(),
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50)),
                  ),
              ],
            ),
            SizedBox(height: 12.r),
            Row(
              children: [
                if (price != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OmrIcon(size: 16.r, color: cs.primary),
                      SizedBox(width: 3.r),
                      Text(
                        price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2),
                        style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.primary),
                      ),
                      Text(
                        'car_detail_per_day'.tr(),
                        style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.45)),
                      ),
                    ],
                  ),
                const Spacer(),
                if (locationLabel.isNotEmpty) ...[
                  Icon(Iconsax.location, size: 14.r, color: cs.onSurface.withValues(alpha: 0.4)),
                  SizedBox(width: 4.r),
                  Flexible(
                    child: Text(
                      locationLabel,
                      style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
