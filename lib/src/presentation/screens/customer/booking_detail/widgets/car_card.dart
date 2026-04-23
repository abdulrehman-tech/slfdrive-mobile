import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/customer/oman_plate.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/booking_detail.dart';
import 'glass_card.dart';

class BookingCarCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingCarCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return BookingGlassCard(
      isDark: isDark,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: CachedNetworkImage(
                    imageUrl: booking.carImageUrl,
                    width: 90.r,
                    height: 72.r,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      width: 90.r,
                      height: 72.r,
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFEEEEEE),
                      child: Icon(Iconsax.car_copy, size: 28.r, color: cs.primary),
                    ),
                  ),
                ),
                SizedBox(width: 14.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.carName,
                        style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      SizedBox(height: 3.r),
                      Text(
                        booking.brand,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                      SizedBox(height: 6.r),
                      Row(
                        children: [
                          OmrIcon(size: 11.r, color: cs.primary),
                          SizedBox(width: 3.r),
                          Text(
                            '${booking.pricePerDay.toInt()}/d',
                            style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: cs.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.r, 0, 14.r, 14.r),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'booking_detail_plate'.tr(),
                      style: TextStyle(
                        fontSize: 11.r,
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OmanPlate(number: booking.plateNumber, code: booking.plateCode, width: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
