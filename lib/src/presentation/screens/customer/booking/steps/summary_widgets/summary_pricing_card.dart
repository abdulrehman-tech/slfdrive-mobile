import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../widgets/omr_icon.dart';
import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';
import 'summary_price_row.dart';

/// Price breakdown on the summary step. Prefers the authoritative backend fare
/// (`/Booking/pre-booking`, held on [BookingData.quote]); shows a spinner while
/// it loads and falls back to a labelled client-side estimate if the quote call
/// fails. Note: the quote's `commissionAmount` is the platform's commission
/// (already excluded from `totalAmount`), NOT a customer charge — so it is not
/// shown here.
class SummaryPricingCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummaryPricingCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = data;

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
          if (d.quote == null && d.quoteLoading)
            _loading(cs)
          else if (d.quote != null)
            ..._quoteBody(cs)
          else
            ..._estimateBody(cs),
        ],
      ),
    );
  }

  Widget _loading(ColorScheme cs) => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.r),
        child: Row(
          children: [
            SizedBox(width: 16.r, height: 16.r, child: const CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10.r),
            Text(
              'booking_summary_calculating'.tr(),
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );

  /// Breakdown from the backend quote — the authoritative fare.
  List<Widget> _quoteBody(ColorScheme cs) {
    final q = data.quote!;
    final unit = (q.isSameDay ? 'booking_dates_hours' : 'booking_dates_days').tr();
    return [
      if ((q.vehicleAmount ?? 0) > 0)
        SummaryPriceRow(
          label: '${'booking_summary_vehicle'.tr()} · ${q.vehicleUnitPrice.toStringAsFixed(0)} × ${q.units} $unit',
          amount: q.vehicleAmount!,
        ),
      if ((q.driverAmount ?? 0) > 0)
        SummaryPriceRow(
          label: '${'booking_summary_driver'.tr()} · ${q.driverUnitPrice.toStringAsFixed(0)} × ${q.units} $unit',
          amount: q.driverAmount!,
        ),
      if (q.totalDeliveryFee > 0)
        SummaryPriceRow(label: 'booking_summary_delivery_fee'.tr(), amount: q.totalDeliveryFee),
      _divider(),
      _totalRow(cs, q.totalAmount),
    ];
  }

  /// Fallback when the quote couldn't be fetched: a clearly-labelled estimate
  /// computed from the selected rates.
  List<Widget> _estimateBody(ColorScheme cs) {
    final d = data;
    final p = d.pricing;
    return [
      if (d.hasCarCharge)
        SummaryPriceRow(
          label: '${'booking_summary_vehicle'.tr()} · ${d.carRate.toStringAsFixed(0)} × ${p.units} ${p.unitLabelKey.tr()}',
          amount: d.carAmount,
        ),
      if (d.hasDriverCharge)
        SummaryPriceRow(
          label: '${'booking_summary_driver'.tr()} · ${d.driverRate.toStringAsFixed(0)} × ${p.units} ${p.unitLabelKey.tr()}',
          amount: d.driverAmount,
        ),
      if (!d.hasCarCharge && !d.hasDriverCharge)
        SummaryPriceRow(
          label: '${p.baseRate.toStringAsFixed(0)} × ${p.units} ${p.unitLabelKey.tr()}',
          amount: p.baseRate * p.units,
        ),
      if (p.deliveryFee > 0)
        SummaryPriceRow(label: 'booking_summary_delivery_fee'.tr(), amount: p.deliveryFee),
      _divider(),
      _totalRow(cs, d.totalPrice),
      SizedBox(height: 6.r),
      Text(
        'booking_summary_estimate_note'.tr(),
        style: TextStyle(
          fontSize: 10.r,
          color: cs.onSurface.withValues(alpha: 0.5),
          fontStyle: FontStyle.italic,
        ),
      ),
    ];
  }

  Widget _divider() => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.r),
        child: Divider(
          height: 1,
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      );

  Widget _totalRow(ColorScheme cs, double total) => Row(
        children: [
          Text(
            'booking_summary_total'.tr(),
            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          const Spacer(),
          OmrIcon(size: 14.r, color: cs.primary),
          SizedBox(width: 3.r),
          Text(
            total.toStringAsFixed(2),
            style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.w900, color: cs.primary),
          ),
        ],
      );
}
