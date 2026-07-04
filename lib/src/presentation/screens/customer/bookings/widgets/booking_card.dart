import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../widgets/omr_icon.dart';
import '../../booking_detail/models/booking_detail.dart' show BookingDetailSeed;
import '../../booking_detail/widgets/pay_booking_sheet.dart';
import '../models/booking_item.dart';
import '../provider/bookings_provider.dart';
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

  void _openDetail(BuildContext context) => context.pushNamed(
        'booking-detail',
        pathParameters: {'id': booking.id.toString()},
        // Seed the detail screen with what we already fetched, so it paints fast.
        extra: BookingDetailSeed(
          vehicleName: booking.vehicleName,
          vehicleImageUrl: booking.vehicleImageUrl,
          driverName: booking.driverName,
          driverPhotoUrl: booking.driverPhotoUrl,
        ),
      );

  Future<void> _pay(BuildContext context) async {
    final provider = context.read<BookingsProvider>();
    final ok = await PayBookingSheet.show(context, bookingId: booking.id, isDark: isDark);
    if (ok == true) provider.load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      clipBehavior: Clip.antiAlias,
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
          if (booking.status == BookingStatus.rejected &&
              (booking.rejectionReason?.trim().isNotEmpty ?? false)) ...[
            SizedBox(height: 10.r),
            _rejectionRow(),
          ],
          SizedBox(height: 14.r),
          _actions(context),
        ],
      ),
    );
  }

  Widget _header() {
    final kind = booking.kind;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _thumbnail(kind),
        SizedBox(width: 12.r),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.title,
                style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.r),
              Text(
                '${kind.title} · ${booking.bookingNo}',
                style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.r),
        BookingStatusBadge(status: booking.status, isDark: isDark),
      ],
    );
  }

  Widget _thumbnail(BookingServiceKind kind) {
    final url = booking.thumbnailUrl;
    final placeholder = Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: kind.color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(kind.icon, size: 22.r, color: kind.color),
    );
    if (url == null) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 44.r,
        height: 44.r,
        fit: BoxFit.cover,
        placeholder: (c, u) => placeholder,
        errorWidget: (c, u, e) => placeholder,
      ),
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
        // Rejected bookings have no payment to make — omit the pill entirely.
        if (booking.showPaymentStatus) _paymentBadge(),
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
    // Corporate bookings are billed to the company, not the customer.
    if (booking.isCorporate && !booking.isPaid) {
      return _badge(
        const Color(0xFF00BFA5),
        Iconsax.building_copy,
        'booking_payment_bill_to_company'.tr(),
      );
    }
    final paid = booking.isPaid;
    final color = paid ? const Color(0xFF4CAF50) : const Color(0xFFFFA726);
    return _badge(
      color,
      paid ? Iconsax.tick_circle_copy : Iconsax.wallet_money_copy,
      paid ? 'bookings_paid'.tr() : 'bookings_awaiting_payment'.tr(),
    );
  }

  Widget _badge(Color color, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: color),
          SizedBox(width: 4.r),
          Text(
            label,
            style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  /// Shown on a rejected booking: the reason the rental company gave.
  Widget _rejectionRow() {
    final reason = booking.rejectionReason?.trim() ?? '';
    const color = Color(0xFFE53935);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.info_circle_copy, size: 13.r, color: color),
          SizedBox(width: 6.r),
          Expanded(
            child: Text(
              '${'bookings_reject_reason'.tr()}: $reason',
              style: TextStyle(fontSize: 11.r, color: color, height: 1.3),
            ),
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
              onTap: () => _pay(context),
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
