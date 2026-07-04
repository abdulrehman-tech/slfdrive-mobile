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
          if (d.hasCarCharge)
            SummaryPriceRow(
              label:
                  '${'booking_summary_vehicle'.tr()} · ${d.carRate.toStringAsFixed(0)} × ${p.units} ${p.unitLabelKey.tr()}',
              amount: d.carAmount,
            ),
          if (d.hasDriverCharge)
            SummaryPriceRow(
              label:
                  '${'booking_summary_driver'.tr()} · ${d.driverRate.toStringAsFixed(0)} × ${p.units} ${p.unitLabelKey.tr()}',
              amount: d.driverAmount,
            ),
          // Fallback: nothing itemised (shouldn't normally happen) — show the
          // combined base line so the breakdown is never empty.
          if (!d.hasCarCharge && !d.hasDriverCharge)
            SummaryPriceRow(
              label: '${p.baseRate.toStringAsFixed(0)} × ${p.units} ${p.unitLabelKey.tr()}',
              amount: p.baseRate * p.units,
            ),
          if (p.deliveryFee > 0)
            SummaryPriceRow(label: 'booking_summary_delivery_fee'.tr(), amount: p.deliveryFee),
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
          // This total is a client-side estimate — the booking isn't priced by
          // the backend until it's created and admin-approved, so the final
          // charged amount is authoritative and may differ.
          SizedBox(height: 6.r),
          Text(
            'booking_summary_estimate_note'.tr(),
            style: TextStyle(
              fontSize: 10.r,
              color: cs.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
