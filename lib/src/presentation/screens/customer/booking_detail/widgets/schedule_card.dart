import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/booking_detail.dart';
import 'glass_card.dart';
import 'mini_block.dart';
import 'section_header.dart';
import 'stage_meta.dart';

class BookingScheduleCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingScheduleCard({
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
              icon: Iconsax.calendar_2_copy,
              color: const Color(0xFF7C4DFF),
              title: 'booking_summary_schedule'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            Row(
              children: [
                Expanded(
                  child: BookingMiniBlock(
                    cs: cs,
                    isDark: isDark,
                    label: 'booking_summary_pickup_date'.tr(),
                    value: formatBookingDate(booking.start),
                  ),
                ),
                SizedBox(width: 10.r),
                Expanded(
                  child: BookingMiniBlock(
                    cs: cs,
                    isDark: isDark,
                    label: 'booking_summary_return_date'.tr(),
                    value: formatBookingDate(booking.end),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.r),
            BookingMiniBlock(
              cs: cs,
              isDark: isDark,
              label: 'booking_summary_days'.tr(),
              value: '${booking.days} ${'booking_dates_days'.tr()}',
            ),
          ],
        ),
      ),
    );
  }
}
