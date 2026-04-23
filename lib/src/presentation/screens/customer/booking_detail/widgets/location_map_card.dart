import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/booking_detail.dart';
import 'glass_card.dart';
import 'section_header.dart';

class BookingLocationMapCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingLocationMapCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return BookingGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSectionHeader(
              cs: cs,
              icon: Iconsax.location_copy,
              color: const Color(0xFFE91E63),
              title: 'booking_detail_logistics'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            Container(
              height: 160.r,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Iconsax.map_1_copy, size: 48.r, color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  Positioned(
                    left: 12.r,
                    bottom: 12.r,
                    right: 12.r,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        booking.pickupLocation,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.r),
            _row(cs, 'booking_summary_pickup_at'.tr(), booking.pickupLocation),
            _row(cs, 'booking_summary_delivery_to'.tr(), booking.dropoffLocation),
          ],
        ),
      ),
    );
  }

  Widget _row(ColorScheme cs, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.r,
            child: Text(label, style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55))),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: cs.onSurface)),
          ),
        ],
      ),
    );
  }
}
