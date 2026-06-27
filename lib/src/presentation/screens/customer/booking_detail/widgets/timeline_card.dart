import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../bookings/models/booking_item.dart';
import '../models/booking_detail.dart';
import 'glass_card.dart';
import 'section_header.dart';

/// Booking lifecycle timeline driven by the real backend status
/// (`pending → approved → [corporate_approved] → completed`, or a terminal
/// `rejected`). Corporate bookings include the extra corporate-approval step.
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

  /// Ordered lifecycle steps for this booking.
  List<BookingStatus> _steps() {
    if (booking.isCorporate) {
      return const [
        BookingStatus.pending,
        BookingStatus.approved,
        BookingStatus.corporateApproved,
        BookingStatus.completed,
      ];
    }
    return const [
      BookingStatus.pending,
      BookingStatus.approved,
      BookingStatus.completed,
    ];
  }

  /// Index of the current status within [steps].
  int _currentIndex(List<BookingStatus> steps) {
    if (booking.status == BookingStatus.completed) return steps.length - 1;
    final idx = steps.indexOf(booking.status);
    if (idx >= 0) return idx;
    // corporateApproved on a non-corporate booking (shouldn't happen) → approved.
    if (booking.status == BookingStatus.corporateApproved ||
        booking.status == BookingStatus.approved) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
            booking.status == BookingStatus.rejected ? _rejected() : _stepper(),
          ],
        ),
      ),
    );
  }

  /// Terminal rejected state: a single red node (plus the rejection reason when
  /// the backend supplies one).
  Widget _rejected() {
    const color = Color(0xFFE53935);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(Iconsax.close_circle_copy, size: 16.r, color: Colors.white),
        ),
        SizedBox(width: 12.r),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.r),
              Text(
                'bookings_status_rejected'.tr(),
                style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: color),
              ),
              if (booking.rejectionReason != null && booking.rejectionReason!.trim().isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4.r),
                  child: Text(
                    booking.rejectionReason!,
                    style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepper() {
    final steps = _steps();
    final current = _currentIndex(steps);
    return Row(
      children: List.generate(steps.length, (i) {
        final completed = i <= current;
        final active = i == current;
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
                      completed ? Iconsax.tick_circle_copy : steps[i].icon,
                      size: 13.r,
                      color: completed ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  SizedBox(height: 6.r),
                  SizedBox(
                    width: 52.r,
                    child: Text(
                      steps[i].label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.r,
                        height: 1.2,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: completed ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 22.r, start: 4.r, end: 4.r),
                    child: Container(
                      height: 2,
                      color: i < current
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
    );
  }
}
