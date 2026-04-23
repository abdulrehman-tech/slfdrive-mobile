import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../widgets/omr_icon.dart';
import '../../models/booking_data.dart';

class SuccessSummaryCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SuccessSummaryCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: [
              _row(cs, 'booking_summary_pickup_date'.tr(), _formatDate(data.startAt)),
              Divider(
                height: 18.r,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
              _row(
                cs,
                'booking_summary_mode'.tr(),
                data.pickupMode == PickupMode.selfPickup
                    ? 'booking_pickup_self'.tr()
                    : 'booking_pickup_delivery'.tr(),
              ),
              Divider(
                height: 18.r,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
              Row(
                children: [
                  Text(
                    'booking_summary_total'.tr(),
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  const Spacer(),
                  OmrIcon(size: 14.r, color: cs.primary),
                  SizedBox(width: 3.r),
                  Text(
                    data.totalPrice.toStringAsFixed(2),
                    style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.w900, color: cs.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(ColorScheme cs, String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.55))),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface)),
      ],
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
