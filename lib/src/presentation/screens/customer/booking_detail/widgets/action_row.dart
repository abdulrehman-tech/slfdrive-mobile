import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    // Contact the driver. Only meaningful when a driver is attached; the screen
    // already gates this row on driver presence. (No reschedule action — the
    // backend has no reschedule endpoint.)
    return GestureDetector(
      onTap: () => ContactLauncher.openPhoneCall(booking.driverPhone ?? ''),
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
    );
  }
}
