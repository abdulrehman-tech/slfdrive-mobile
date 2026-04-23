import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PaymentSecurityNote extends StatelessWidget {
  final bool isDark;
  const PaymentSecurityNote({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.shield_tick_copy, size: 18.r, color: const Color(0xFF4CAF50)),
          SizedBox(width: 10.r),
          Expanded(
            child: Text(
              'booking_payment_security'.tr(),
              style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.7), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
