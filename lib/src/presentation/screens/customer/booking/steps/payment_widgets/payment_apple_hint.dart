import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/booking_glass_card.dart';

class PaymentAppleHint extends StatelessWidget {
  final bool isDark;
  const PaymentAppleHint({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(18.r),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.apple, size: 26.r, color: Colors.white),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'booking_payment_apple_title'.tr(),
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 3.r),
                Text(
                  'booking_payment_apple_desc'.tr(),
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
