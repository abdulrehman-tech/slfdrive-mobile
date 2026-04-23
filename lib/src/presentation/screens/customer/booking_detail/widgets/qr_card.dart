import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/booking_detail.dart';
import 'glass_card.dart';
import 'qr_painter.dart';

class BookingQrCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingQrCard({
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
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'booking_detail_qr_title'.tr(),
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    'booking_detail_qr_subtitle'.tr(),
                    style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.r),
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.black12),
              ),
              child: CustomPaint(painter: BookingQrMockPainter(seed: booking.ref.hashCode)),
            ),
          ],
        ),
      ),
    );
  }
}
