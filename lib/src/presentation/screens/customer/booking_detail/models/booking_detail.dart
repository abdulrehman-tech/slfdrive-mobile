import '../../../../../core/models/booking/booking.dart';

enum BookingTimelineStage { confirmed, pickedUp, inTrip, returned }

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
    this.driverName,
    this.driverAvatar,
    this.driverPhone,
  });

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
    return BookingDetail(
      id: b.id,
      ref: b.bookingNo ?? 'SLF${b.id}',
      carName: b.serviceType?.trim().isNotEmpty == true ? b.serviceType! : 'Booking #${b.id}',
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
      driverName: b.driverFullName,
      driverAvatar: null,
      driverPhone: b.driverPhoneNumber,
    );
  }
}
