import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/booking_detail.dart';
import 'glass_card.dart';
import 'section_header.dart';
import 'stage_meta.dart';

class BookingTimelineCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingTimelineCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    const stages = BookingTimelineStage.values;
    return BookingGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSectionHeader(
              cs: cs,
              icon: Iconsax.activity_copy,
              color: const Color(0xFF3D5AFE),
              title: 'booking_detail_timeline'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 16.r),
            Row(
              children: List.generate(stages.length, (i) {
                final completed = stages.indexOf(booking.stage) >= i;
                final active = stages.indexOf(booking.stage) == i;
                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 26.r,
                            height: 26.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: completed
                                  ? cs.primary
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05)),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: cs.primary.withValues(alpha: 0.4),
                                        blurRadius: 8.r,
                                        offset: Offset(0, 3.r),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              completed ? Iconsax.tick_circle_copy : bookingStageIcon(stages[i]),
                              size: 13.r,
                              color: completed ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                          SizedBox(height: 6.r),
                          Text(
                            bookingStageLabelKey(stages[i]).tr(),
                            style: TextStyle(
                              fontSize: 9.r,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: completed ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      if (i < stages.length - 1)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(bottom: 22.r, start: 4.r, end: 4.r),
                            child: Container(
                              height: 2,
                              color: completed
                                  ? cs.primary
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.05)),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
