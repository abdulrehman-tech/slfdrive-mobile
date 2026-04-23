import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../utils/contact_launcher.dart';
import '../models/booking_detail.dart';

class BookingActionRow extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingActionRow({
    super.key,
    required this.booking,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.calendar_edit_copy, size: 16.r, color: cs.onSurface),
                  SizedBox(width: 6.r),
                  Text(
                    'booking_detail_reschedule'.tr(),
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.r),
        Expanded(
          child: GestureDetector(
            onTap: () => ContactLauncher.openPhoneCall(booking.driverPhone ?? '+96890000000'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.r),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C2485).withValues(alpha: 0.3),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.r),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.call_copy, size: 16.r, color: Colors.white),
                  SizedBox(width: 6.r),
                  Text(
                    'booking_detail_contact'.tr(),
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
