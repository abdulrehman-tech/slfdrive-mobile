import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../widgets/omr_icon.dart';
import '../../widgets/booking_glass_card.dart';

class PaymentWalletHint extends StatelessWidget {
  final bool isDark;
  const PaymentWalletHint({super.key, required this.isDark});

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
              color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.wallet_3_copy, size: 22.r, color: const Color(0xFF00BCD4)),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'booking_payment_wallet_title'.tr(),
                      style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                    const Spacer(),
                    OmrIcon(size: 12.r, color: const Color(0xFF00BCD4)),
                    SizedBox(width: 3.r),
                    Text(
                      '42.50',
                      style: TextStyle(
                        fontSize: 14.r,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.r),
                Text(
                  'booking_payment_wallet_desc'.tr(),
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
