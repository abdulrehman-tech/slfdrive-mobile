import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';

class PaymentMethodGrid extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const PaymentMethodGrid({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const methods = <(PaymentMethod, IconData, String, Color)>[
      (PaymentMethod.card, Iconsax.card_copy, 'booking_payment_card', Color(0xFF3D5AFE)),
      (PaymentMethod.applePay, Iconsax.mobile_copy, 'booking_payment_apple', Color(0xFF7C4DFF)),
      (PaymentMethod.wallet, Iconsax.wallet_3_copy, 'booking_payment_wallet', Color(0xFF00BCD4)),
      (PaymentMethod.cashOnDelivery, Iconsax.money_copy, 'booking_payment_cash', Color(0xFF4CAF50)),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10.r,
      mainAxisSpacing: 10.r,
      childAspectRatio: 1.6,
      children: methods.map((m) {
        final active = data.paymentMethod == m.$1;
        return GestureDetector(
          onTap: () => data.setPaymentMethod(m.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: active
                  ? m.$4.withValues(alpha: isDark ? 0.2 : 0.12)
                  : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: active
                    ? m.$4.withValues(alpha: 0.45)
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                width: active ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: active ? m.$4 : m.$4.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(m.$2, size: 18.r, color: active ? Colors.white : m.$4),
                ),
                const Spacer(),
                Text(
                  m.$3.tr(),
                  style: TextStyle(
                    fontSize: 12.r,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
