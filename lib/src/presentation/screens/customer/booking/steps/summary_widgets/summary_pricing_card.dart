import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../widgets/omr_icon.dart';
import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';
import 'summary_price_row.dart';

class SummaryPricingCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummaryPricingCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = data;
    final p = d.pricing;

    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.receipt_item_copy,
            iconColor: const Color(0xFF00BCD4),
            title: 'booking_summary_price'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 12.r),
          SummaryPriceRow(
            label: '${p.basePerDay.toStringAsFixed(0)} × ${p.days} ${'booking_dates_days'.tr()}',
            amount: p.basePerDay * p.days,
          ),
          if (p.extrasPerDay > 0)
            SummaryPriceRow(
              label: 'booking_summary_extras'.tr(),
              amount: p.extrasPerDay * p.days,
            ),
          if (p.deliveryFee > 0)
            SummaryPriceRow(label: 'booking_summary_delivery_fee'.tr(), amount: p.deliveryFee),
          SummaryPriceRow(label: 'booking_summary_vat'.tr(), amount: p.vat),
          if (d.promoCode != null)
            SummaryPriceRow(
              label: '${'booking_summary_discount'.tr()} (${d.promoCode})',
              amount: -d.promoDiscount,
              highlight: const Color(0xFF4CAF50),
            ),
          SizedBox(height: 10.r),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
          SizedBox(height: 10.r),
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
                d.totalPrice.toStringAsFixed(2),
                style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.w900, color: cs.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
