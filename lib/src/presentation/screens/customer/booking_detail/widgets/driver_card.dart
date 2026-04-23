import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../utils/contact_launcher.dart';
import '../models/booking_detail.dart';
import 'glass_card.dart';

class BookingDriverCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingDriverCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return BookingGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: booking.driverAvatar!,
              imageBuilder: (_, img) => Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: img, fit: BoxFit.cover),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 2),
                ),
              ),
              errorWidget: (_, _, _) => CircleAvatar(
                radius: 24.r,
                backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                child: Icon(Iconsax.user_copy, size: 20.r, color: cs.primary),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'booking_detail_driver'.tr(),
                    style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    booking.driverName!,
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ContactLauncher.openWhatsApp(
                booking.driverPhone ?? '',
                message: 'Hi, regarding booking ${booking.ref}',
              ),
              child: Container(
                width: 40.r,
                height: 40.r,
                margin: EdgeInsetsDirectional.only(end: 8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(Iconsax.message_copy, color: const Color(0xFF25D366), size: 17.r),
              ),
            ),
            GestureDetector(
              onTap: () => ContactLauncher.openPhoneCall(booking.driverPhone ?? ''),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(Iconsax.call_copy, color: cs.primary, size: 17.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
