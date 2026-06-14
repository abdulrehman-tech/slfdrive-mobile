import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/booking_item.dart';
import 'booking_status_badge.dart';
import 'date_column.dart';

class BookingCard extends StatelessWidget {
  final BookingItem booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.cs,
  });

  void _openDetail(BuildContext context) =>
      context.pushNamed('booking-detail', pathParameters: {'id': booking.id.toString()});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 20.r,
                offset: Offset(0, 6.r),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(),
              SizedBox(height: 12.r),
              _dateRange(),
              SizedBox(height: 12.r),
              _footer(),
              SizedBox(height: 14.r),
              _actions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final kind = booking.kind;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: kind.color.withValues(alpha: isDark ? 0.2 : 0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(kind.icon, size: 22.r, color: kind.color),
        ),
        SizedBox(width: 12.r),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kind.title,
                style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.r),
              Text(
                booking.bookingNo,
                style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.r),
        BookingStatusBadge(status: booking.status, isDark: isDark),
      ],
    );
  }

  Widget _dateRange() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: DateColumn(
              label: 'bookings_pickup'.tr(),
              date: booking.pickupDate,
              icon: Iconsax.calendar_add,
              color: const Color(0xFF3D5AFE),
              isDark: isDark,
              cs: cs,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            child: Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.forward, size: 14.r, color: cs.primary),
            ),
          ),
          Expanded(
            child: DateColumn(
              label: 'bookings_dropoff'.tr(),
              date: booking.dropoffDate,
              icon: Iconsax.calendar_remove,
              color: const Color(0xFFE91E63),
              isDark: isDark,
              cs: cs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Row(
      children: [
        _paymentBadge(),
        const Spacer(),
        OmrIcon(size: 13.r, color: cs.primary),
        SizedBox(width: 3.r),
        Text(
          booking.totalPrice.toStringAsFixed(2),
          style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w900, color: cs.primary),
        ),
      ],
    );
  }

  Widget _paymentBadge() {
    final paid = booking.isPaid;
    final color = paid ? const Color(0xFF4CAF50) : const Color(0xFFFFA726);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(paid ? Iconsax.tick_circle_copy : Iconsax.wallet_money_copy, size: 12.r, color: color),
          SizedBox(width: 4.r),
          Text(
            paid ? 'bookings_paid'.tr() : 'bookings_awaiting_payment'.tr(),
            style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openDetail(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.r),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  'bookings_view_details'.tr(),
                  style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.primary),
                ),
              ),
            ),
          ),
        ),
        if (booking.canPay) ...[
          SizedBox(width: 10.r),
          Expanded(
            child: GestureDetector(
              onTap: () => _openDetail(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.r),
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0C2485).withValues(alpha: 0.3),
                      blurRadius: 8.r,
                      offset: Offset(0, 3.r),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'pay_now'.tr(),
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
