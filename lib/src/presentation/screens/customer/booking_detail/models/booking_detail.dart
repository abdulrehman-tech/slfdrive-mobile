import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/models/booking/booking.dart';

enum BookingTimelineStage { confirmed, pickedUp, inTrip, returned }

/// Friendly label for a booking's service type (vehicle / driver / both).
String _serviceLabel(Booking b) {
  final s = (b.serviceType ?? '').toLowerCase();
  if (s.contains('with') || b.serviceTypeId == 11) return 'booking_kind_vehicle_driver'.tr();
  if (s.contains('driver') || b.serviceTypeId == 9) return 'booking_kind_driver'.tr();
  return 'booking_kind_vehicle'.tr();
}

class BookingDetail {
  final int id;
  final String ref;
  final String carName;
  final String carImageUrl;
  final String brand;
  final String plateNumber;
  final String plateCode;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime start;
  final DateTime end;
  final double pricePerDay;
  final double extrasPerDay;
  final double deliveryFee;
  final String paymentMethod;
  final String? driverName;
  final String? driverAvatar;
  final String? driverPhone;
  final BookingTimelineStage stage;
  final String statusLabel;
  final bool isApproved;
  final bool isPending;
  final bool isPaid;

  const BookingDetail({
    required this.id,
    required this.ref,
    required this.carName,
    required this.carImageUrl,
    required this.brand,
    required this.plateNumber,
    required this.plateCode,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.start,
    required this.end,
    required this.pricePerDay,
    required this.extrasPerDay,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.stage,
    this.statusLabel = '',
    this.isApproved = false,
    this.isPending = false,
    this.isPaid = false,
    this.driverName,
    this.driverAvatar,
    this.driverPhone,
  });

  /// Customer can pay once an admin has approved the booking and it isn't paid.
  bool get canPay => isApproved && !isPaid;

  int get days {
    final d = end.difference(start).inDays;
    return d < 1 ? 1 : d + 1;
  }

  double get subtotal => (pricePerDay + extrasPerDay) * days + deliveryFee;
  double get vat => subtotal * 0.05;
  double get total => subtotal + vat;

  /// True when the booking is completed and eligible for a customer review.
  bool get isCompleted => stage == BookingTimelineStage.returned;

  /// Maps a backend [Booking] to the detail view model. `BookingResponseDto`
  /// doesn't carry vehicle display/plate fields or a price breakdown, so those
  /// fall back to empty/derived values; the amount is shown as the lump total.
  factory BookingDetail.fromBooking(Booking b) {
    final start = b.fromDate ?? DateTime.now();
    final end = b.toDate ?? start;
    final dayCount = () {
      final d = end.difference(start).inDays;
      return d < 1 ? 1 : d + 1;
    }();
    final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
    final stage = (b.completedAt != null || s.contains('complete'))
        ? BookingTimelineStage.returned
        : (s.contains('trip') || s.contains('progress') || s.contains('ongoing'))
            ? BookingTimelineStage.inTrip
            : s.contains('picked')
                ? BookingTimelineStage.pickedUp
                : BookingTimelineStage.confirmed;
    final pay = (b.paymentStatus ?? '').toLowerCase();
    final isApproved = s.contains('approved'); // covers "approved" + "CorporateApproved"
    final isPending = s.contains('pending');
    final isPaid = pay.contains('paid');
    return BookingDetail(
      id: b.id,
      ref: b.bookingNo ?? 'SLF${b.id}',
      carName: _serviceLabel(b),
      carImageUrl: '',
      brand: '',
      plateNumber: '',
      plateCode: '',
      pickupLocation: '',
      dropoffLocation: '',
      start: start,
      end: end,
      // Backend returns a lump total; spread it across days with no VAT split.
      pricePerDay: dayCount == 0 ? (b.totalAmount ?? 0) : (b.totalAmount ?? 0) / dayCount,
      extrasPerDay: 0,
      deliveryFee: 0,
      paymentMethod: b.paymentStatus ?? '',
      stage: stage,
      statusLabel: b.status ?? '',
      isApproved: isApproved,
      isPending: isPending,
      isPaid: isPaid,
      driverName: b.driverFullName,
      driverAvatar: null,
      driverPhone: b.driverPhoneNumber,
    );
  }
}
