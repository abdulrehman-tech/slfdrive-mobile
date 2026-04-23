import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/booking_detail.dart';
import 'glass_card.dart';
import 'section_header.dart';

class BookingPriceCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingPriceCard({
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
              icon: Iconsax.receipt_item_copy,
              color: const Color(0xFF00BCD4),
              title: 'booking_summary_price'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            _priceRow(
              cs,
              '${booking.pricePerDay.toInt()} × ${booking.days} ${'booking_dates_days'.tr()}',
              booking.pricePerDay * booking.days,
            ),
            if (booking.extrasPerDay > 0)
              _priceRow(cs, 'booking_summary_extras'.tr(), booking.extrasPerDay * booking.days),
            if (booking.deliveryFee > 0) _priceRow(cs, 'booking_summary_delivery_fee'.tr(), booking.deliveryFee),
            _priceRow(cs, 'booking_summary_vat'.tr(), booking.vat),
            Divider(
              height: 20.r,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
            Row(
              children: [
                Text(
                  'booking_summary_total'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                const Spacer(),
                OmrIcon(size: 14.r, color: cs.primary),
                SizedBox(width: 3.r),
                Text(
                  booking.total.toStringAsFixed(2),
                  style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.w900, color: cs.primary),
                ),
              ],
            ),
            SizedBox(height: 10.r),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.card_copy, size: 12.r, color: cs.primary),
                  SizedBox(width: 5.r),
                  Text(
                    'booking_detail_paid_with'.tr(args: [booking.paymentMethod]),
                    style: TextStyle(fontSize: 10.r, color: cs.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(ColorScheme cs, String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.r),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6))),
          ),
          OmrIcon(size: 11.r, color: cs.onSurface.withValues(alpha: 0.7)),
          SizedBox(width: 2.r),
          Text(
            amount.toStringAsFixed(2),
            style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
