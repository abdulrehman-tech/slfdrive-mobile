import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../utils/contact_launcher.dart';
import '../../../../widgets/omr_icon.dart';
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

  Widget _fallbackAvatar() => CircleAvatar(
        radius: 24.r,
        backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
        child: Icon(Iconsax.user_copy, size: 20.r, color: cs.primary),
      );

  Widget _avatar() {
    final url = booking.driverAvatar;
    if (url == null || url.isEmpty) return _fallbackAvatar();
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (_, img) => Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: img, fit: BoxFit.cover),
          border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 2),
        ),
      ),
      errorWidget: (_, _, _) => _fallbackAvatar(),
    );
  }

  /// "8 yrs · English, Arabic · Muscat" — only the parts the API returned.
  String get _driverSubtitle {
    final parts = <String>[
      if (booking.driverExperienceYears != null && booking.driverExperienceYears! > 0)
        '${booking.driverExperienceYears} ${'booking_detail_years'.tr()}',
      if ((booking.driverLanguages ?? '').trim().isNotEmpty) booking.driverLanguages!.trim(),
      if ((booking.driverLocation ?? '').trim().isNotEmpty) booking.driverLocation!.trim(),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return BookingGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            _avatar(),
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
                    booking.driverName ?? 'Driver',
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_driverSubtitle.isNotEmpty) ...[
                    SizedBox(height: 3.r),
                    Text(
                      _driverSubtitle,
                      style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Driver-only rate (backend `driverAmount` split over the
                  // billed units), shown when the driver is a paid line.
                  if (booking.driverAmount > 0) ...[
                    SizedBox(height: 6.r),
                    Row(
                      children: [
                        OmrIcon(size: 11.r, color: cs.primary),
                        SizedBox(width: 3.r),
                        Text(
                          '${booking.driverUnitRate.toInt()}/${booking.isHourly ? 'h' : 'd'}',
                          style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: cs.primary),
                        ),
                      ],
                    ),
                  ],
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
