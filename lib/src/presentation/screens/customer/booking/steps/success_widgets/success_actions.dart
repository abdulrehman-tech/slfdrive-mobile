import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../constants/color_constants.dart';

class SuccessActions extends StatelessWidget {
  const SuccessActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.go('/home'),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.r),
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.r),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'booking_success_home'.tr(),
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.r),
        GestureDetector(
          onTap: () {
            context.go('/home');
            // Further: navigate to bookings detail — wired in phase 3.
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.r),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                'booking_success_view_booking'.tr(),
                style: TextStyle(
                  fontSize: 13.r,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
