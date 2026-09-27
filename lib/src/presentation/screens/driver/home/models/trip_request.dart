import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/models/booking/booking.dart';
import '../../../../utils/date_labels.dart';

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

  /// Corporate bookings need the employer's approval before the driver may
  /// accept (the backend rejects the approve call until then), so the card
  /// shows a waiting state instead of an Accept button.
  final bool awaitingCorporateApproval;

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
    this.awaitingCorporateApproval = false,
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
      customer: (b.customerFullName?.trim().isNotEmpty ?? false) ? b.customerFullName!.trim() : 'common_customer'.tr(),
      customerPhone: (b.customerPhoneNumber?.trim().isNotEmpty ?? false) ? b.customerPhoneNumber!.trim() : null,
      avatarUrl: avatarUrl,
      serviceKey: serviceKeyFor(b.serviceType),
      isCorporate: b.isCorporate,
      awaitingCorporateApproval: b.isCorporate && b.statusId == 5,
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

/// "28 Jun – 30 Jun" (localized month abbreviations), or a single date when
/// the range collapses, or '' when dates are missing.
String dateRangeLabel(DateTime? from, DateTime? to) {
  if (from == null && to == null) return '';
  if (from == null) return formatDayMonth(to!.toLocal());
  if (to == null) return formatDayMonth(from.toLocal());
  return formatDayRange(from.toLocal(), to.toLocal());
}
