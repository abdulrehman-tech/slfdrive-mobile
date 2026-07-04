import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../../bookings/models/booking_item.dart' show BookingStatus;
import '../models/booking_detail.dart';
import 'glass_card.dart';
import 'section_header.dart';

class BookingPriceCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingPriceCard({super.key, required this.booking, required this.isDark, required this.cs});

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
            ..._breakdownRows(cs),
            if (booking.extrasPerDay > 0)
              _priceRow(cs, 'booking_summary_extras'.tr(), booking.extrasPerDay * booking.days),
            if (booking.deliveryFee > 0) _priceRow(cs, 'booking_summary_delivery_fee'.tr(), booking.deliveryFee),
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
            // A rejected booking has no payment to make — hide the status pill.
            if (booking.status != BookingStatus.rejected) ...[
              SizedBox(height: 10.r),
              _paymentStatusBadge(),
            ],
          ],
        ),
      ),
    );
  }

  /// Localized label for a backend payment-type name (cash / card / OmPay).
  /// Returns null for an unknown/empty method so the badge stays just "Paid".
  String? _methodLabel(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'cash':
        return 'pay_method_cash'.tr();
      case 'card':
        return 'pay_method_card'.tr();
      case 'ompay':
        return 'OmPay';
      default:
        return (name != null && name.trim().isNotEmpty) ? name.trim() : null;
    }
  }

  /// Payment-status pill: green "Paid · {method}" once settled, amber "Awaiting
  /// payment" while pending. Corporate bookings read "Billed to company".
  Widget _paymentStatusBadge() {
    final Color color;
    final IconData icon;
    final String label;
    if (booking.isCorporate && !booking.isPaid) {
      color = const Color(0xFF00BFA5);
      icon = Iconsax.building_copy;
      label = 'booking_payment_bill_to_company'.tr();
    } else if (booking.isPaid) {
      color = const Color(0xFF4CAF50);
      icon = Iconsax.tick_circle_copy;
      final method = _methodLabel(booking.paymentMethodName);
      label = method == null ? 'bookings_paid'.tr() : '${'bookings_paid'.tr()} · $method';
    } else {
      color = const Color(0xFFFFA726);
      icon = Iconsax.clock_copy;
      label = 'bookings_awaiting_payment'.tr();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: color),
          SizedBox(width: 5.r),
          Text(
            label,
            style: TextStyle(fontSize: 10.r, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Price breakdown lines. Shows the vehicle and driver charges separately
  /// when the backend supplies them (`vehicleAmount` / `driverAmount`), each as
  /// `rate × units {days|hours}`. Same-day bookings are billed per hour. Falls
  /// back to a single derived line when no breakdown is present.
  List<Widget> _breakdownRows(ColorScheme cs) {
    final unit = booking.unitLabelKey.tr();
    final units = booking.units;
    final rows = <Widget>[];

    if (booking.vehicleAmount > 0) {
      rows.add(_priceRow(
        cs,
        '${'booking_summary_vehicle'.tr()} · ${booking.vehicleUnitRate.toStringAsFixed(2)} × $units $unit',
        booking.vehicleAmount,
      ));
    }
    if (booking.driverAmount > 0) {
      rows.add(_priceRow(
        cs,
        '${'booking_summary_driver'.tr()} · ${booking.driverUnitRate.toStringAsFixed(2)} × $units $unit',
        booking.driverAmount,
      ));
    }

    // No per-side breakdown from the backend — show the derived lump line.
    if (rows.isEmpty) {
      final rate = units > 0 ? booking.total / units : booking.total;
      rows.add(_priceRow(cs, '${rate.toStringAsFixed(2)} × $units $unit', booking.total));
    }
    return rows;
  }

  Widget _priceRow(ColorScheme cs, String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.r),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
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
