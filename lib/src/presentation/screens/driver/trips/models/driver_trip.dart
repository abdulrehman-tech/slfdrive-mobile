import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/models/booking/booking.dart';
import '../../../../../core/utils/booking_status.dart';
import '../../home/models/trip_request.dart' show serviceKeyFor;
import '../../../../utils/date_labels.dart';

enum DriverTripStatus { active, completed, cancelled }

class DriverTrip {
  final String id;
  final int bookingId;
  final String bookingNo;
  final String customer;
  final String? avatarUrl;

  /// Resolved drop-off place name, or null when none is known. Raw coordinates
  /// are never shown — they read as noise to a driver.
  final String? destination;

  /// Localised service ("Driver only", "Car + driver"…) shown when there is no
  /// destination to display.
  final String serviceLabel;
  final double fare;
  final String time;
  final DriverTripStatus status;

  // Active-only
  final String? pickup;
  final String? distance;

  // Completed-only
  final double? rating;

  // Cancelled-only
  final String? reason;

  const DriverTrip({
    required this.id,
    required this.bookingId,
    required this.bookingNo,
    required this.customer,
    this.avatarUrl,
    this.destination,
    required this.serviceLabel,
    required this.fare,
    required this.time,
    required this.status,
    this.pickup,
    this.distance,
    this.rating,
    this.reason,
  });

  /// Builds a driver-facing trip from a [Booking]. Returns null for bookings
  /// that aren't trips yet (still pending the driver's own approval — those
  /// surface as requests on the home screen).
  static DriverTrip? fromBooking(
    Booking b, {
    String? pickupName,
    String? dropoffName,
    String? avatarUrl,
  }) {
    final status = _statusFromBooking(b);
    if (status == null) return null;
    final pickup = (pickupName != null && pickupName.isNotEmpty) ? pickupName : null;
    final dropoff = (dropoffName != null && dropoffName.isNotEmpty) ? dropoffName : null;
    return DriverTrip(
      id: b.id.toString(),
      bookingId: b.id,
      bookingNo: b.bookingNo ?? 'SLF${b.id}',
      customer: (b.customerFullName?.trim().isNotEmpty ?? false) ? b.customerFullName!.trim() : 'common_customer'.tr(),
      avatarUrl: avatarUrl,
      destination: dropoff,
      serviceLabel: serviceKeyFor(b.serviceType).tr(),
      pickup: pickup,
      fare: b.totalAmount ?? 0,
      time: _dateLabel(b.fromDateTime ?? b.confirmedAt ?? b.completedAt),
      status: status,
      reason: b.rejectionReason,
    );
  }
}

/// Maps the backend booking_status onto the driver's three trip buckets via
/// the shared statusId-first classifier. `pending` returns null — it's a
/// request, not a trip yet.
DriverTripStatus? _statusFromBooking(Booking b) {
  switch (classifyBooking(b)) {
    case BookingBucket.cancelled:
      return DriverTripStatus.cancelled;
    case BookingBucket.completed:
      return DriverTripStatus.completed;
    case BookingBucket.active:
      return DriverTripStatus.active; // incl. CorporateApproved
    case BookingBucket.pending:
      return null; // pending → handled as a request on home
  }
}

/// Locale-aware "21 Aug 2026, 5:00 PM" from an ISO timestamp, or '' when
/// unparseable.
String _dateLabel(String? iso) {
  final dt = DateTime.tryParse(iso ?? '');
  return dt == null ? '' : formatDayMonthYearTime(dt.toLocal());
}
