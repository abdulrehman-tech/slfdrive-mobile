import '../../../../../core/models/booking/booking.dart';

/// A pending booking awaiting the driver's accept/decline decision, enriched
/// with everything the driver needs to judge the request: who, what service,
/// when (dates + duration), where (resolved place names), and the fare.
class TripRequest {
  final int bookingId;
  final String reference; // bookingNo
  final String customer;
  final String? customerPhone;
  final String? avatarUrl;

  /// Localization key for the requested service (driver / vehicle / both).
  final String serviceKey;
  final bool isCorporate;

  /// Resolved place names (or '' when no coordinates were supplied).
  final String pickup;
  final String dropoff;

  /// Compact date range label, e.g. "28 Jun – 30 Jun".
  final String dateRange;
  final int days;

  /// Total fare (OMR) and the derived per-day rate.
  final double fare;
  final double? perDay;

  const TripRequest({
    required this.bookingId,
    required this.reference,
    required this.customer,
    required this.customerPhone,
    required this.avatarUrl,
    required this.serviceKey,
    required this.isCorporate,
    required this.pickup,
    required this.dropoff,
    required this.dateRange,
    required this.days,
    required this.fare,
    required this.perDay,
  });

  bool get hasPickup => pickup.isNotEmpty;
  bool get hasDropoff => dropoff.isNotEmpty;

  /// Builds a request card from a pending [Booking]. Place names are resolved
  /// by the caller (which has API access) and passed in.
  factory TripRequest.fromBooking(
    Booking b, {
    required String pickup,
    required String dropoff,
    String? avatarUrl,
  }) {
    return TripRequest(
      bookingId: b.id,
      reference: b.bookingNo ?? 'SLF${b.id}',
      customer: (b.customerFullName?.trim().isNotEmpty ?? false) ? b.customerFullName!.trim() : 'Customer',
      customerPhone: (b.customerPhoneNumber?.trim().isNotEmpty ?? false) ? b.customerPhoneNumber!.trim() : null,
      avatarUrl: avatarUrl,
      serviceKey: serviceKeyFor(b.serviceType),
      isCorporate: b.isCorporate,
      pickup: pickup,
      dropoff: dropoff,
      dateRange: dateRangeLabel(b.fromDate, b.toDate),
      days: b.durationDays,
      fare: b.totalAmount ?? 0,
      perDay: b.perDayAmount,
    );
  }
}

/// Maps the backend `serviceType` string onto an existing booking-flow
/// localization key, so the request card labels match the customer's wording.
String serviceKeyFor(String? serviceType) {
  switch ((serviceType ?? '').toLowerCase()) {
    case 'driver':
      return 'booking_service_driver_only';
    case 'vehicle-with-driver':
    case 'vehicle_with_driver':
      return 'booking_service_car_with_driver';
    case 'vehicle':
      return 'booking_service_rent_car';
    default:
      return 'booking_service_rent_car';
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "28 Jun – 30 Jun", or a single date when the range collapses, or '' when
/// dates are missing.
String dateRangeLabel(DateTime? from, DateTime? to) {
  String one(DateTime d) => '${d.day} ${_months[d.month - 1]}';
  if (from == null && to == null) return '';
  if (from == null) return one(to!.toLocal());
  if (to == null) return one(from.toLocal());
  final f = from.toLocal();
  final t = to.toLocal();
  if (f.year == t.year && f.month == t.month && f.day == t.day) return one(f);
  return '${one(f)} – ${one(t)}';
}
