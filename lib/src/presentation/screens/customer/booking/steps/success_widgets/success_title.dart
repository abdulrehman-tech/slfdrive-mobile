import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuccessTitle extends StatelessWidget {
  const SuccessTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'booking_success_title'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, letterSpacing: -0.2),
        ),
        SizedBox(height: 6.r),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.r),
          child: Text(
            'booking_success_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.6), height: 1.5),
          ),
        ),
      ],
    );
  }
}
