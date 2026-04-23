import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../models/booking_item.dart';
import 'booking_price_badge.dart';
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
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
              _buildImage(),
              _buildDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          child: CachedNetworkImage(
            imageUrl: booking.carImageUrl,
            height: 140.r,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, _) => _imageFallback(),
            errorWidget: (_, _, _) => _imageFallback(),
          ),
        ),
        Positioned(
          top: 10.r,
          left: 10.r,
          child: BookingStatusBadge(status: booking.status, isDark: isDark),
        ),
        Positioned(
          top: 10.r,
          right: 10.r,
          child: BookingPriceBadge(price: booking.totalPrice),
        ),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 140.r,
      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(
          Iconsax.car_copy,
          color: cs.primary.withValues(alpha: 0.4),
          size: 36.r,
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(),
          SizedBox(height: 12.r),
          _buildDateRange(),
          SizedBox(height: 12.r),
          _buildLocationRow(),
          SizedBox(height: 14.r),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            booking.carName,
            style: TextStyle(
              fontSize: 15.r,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (booking.driverName != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF)
                  .withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.driver_copy,
                  size: 11.r,
                  color: const Color(0xFF7C4DFF),
                ),
                SizedBox(width: 4.r),
                Text(
                  'bookings_with_driver'.tr(),
                  style: TextStyle(
                    fontSize: 9.r,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7C4DFF),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDateRange() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
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
              child: Icon(
                CupertinoIcons.forward,
                size: 14.r,
                color: cs.primary,
              ),
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

  Widget _buildLocationRow() {
    return Row(
      children: [
        Icon(
          Iconsax.location_copy,
          size: 14.r,
          color: cs.onSurface.withValues(alpha: 0.5),
        ),
        SizedBox(width: 5.r),
        Expanded(
          child: Text(
            booking.pickupLocation,
            style: TextStyle(
              fontSize: 12.r,
              color: cs.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (booking.driverName != null) ...[
          CachedNetworkImage(
            imageUrl: booking.driverAvatarUrl!,
            imageBuilder: (_, img) =>
                CircleAvatar(radius: 12.r, backgroundImage: img),
            placeholder: (_, _) =>
                CircleAvatar(radius: 12.r, backgroundColor: const Color(0xFFEEEEEE)),
            errorWidget: (_, _, _) =>
                CircleAvatar(radius: 12.r, backgroundColor: const Color(0xFFEEEEEE)),
          ),
          SizedBox(width: 6.r),
          Text(
            booking.driverName!,
            style: TextStyle(
              fontSize: 11.r,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final isFinished = booking.status == BookingStatus.completed ||
        booking.status == BookingStatus.cancelled;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isFinished) {
                context.pushNamed('car-listing');
              } else {
                context.pushNamed(
                  'booking-detail',
                  pathParameters: {'id': booking.carName.hashCode.toString()},
                );
              }
            },
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
                  isFinished
                      ? 'bookings_rebook'.tr()
                      : 'bookings_view_details'.tr(),
                  style: TextStyle(
                    fontSize: 12.r,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (booking.status == BookingStatus.confirmed) ...[
          SizedBox(width: 10.r),
          GestureDetector(
            onTap: () => context
                .pushNamed('booking-detail', pathParameters: {'id': 'mock'}),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: 16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935)
                    .withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE53935).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'bookings_cancel'.tr(),
                style: TextStyle(
                  fontSize: 12.r,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE53935),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
