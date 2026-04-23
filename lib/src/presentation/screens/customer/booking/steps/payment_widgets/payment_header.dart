import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentHeader extends StatelessWidget {
  const PaymentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_payment_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_payment_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
      ],
    );
  }
}
