import '../../../../../core/models/booking/booking.dart';

enum DriverTripStatus { active, completed, cancelled }

class DriverTrip {
  final String id;
  final int bookingId;
  final String bookingNo;
  final String customer;
  final String? avatarUrl;
  final String destination;
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
    required this.destination,
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
    final pickup = (pickupName != null && pickupName.isNotEmpty)
        ? pickupName
        : _locationLabel(b.pickupLat, b.pickupLon);
    final dropoff = (dropoffName != null && dropoffName.isNotEmpty)
        ? dropoffName
        : _locationLabel(b.dropoffLat, b.dropoffLon);
    return DriverTrip(
      id: b.id.toString(),
      bookingId: b.id,
      bookingNo: b.bookingNo ?? 'SLF${b.id}',
      customer: (b.customerFullName?.trim().isNotEmpty ?? false) ? b.customerFullName!.trim() : 'Customer',
      avatarUrl: avatarUrl,
      destination: dropoff ?? b.serviceType ?? '',
      pickup: pickup,
      fare: b.totalAmount ?? 0,
      time: _dateLabel(b.fromDateTime ?? b.confirmedAt ?? b.completedAt),
      status: status,
      reason: b.rejectionReason,
    );
  }
}

/// Maps the backend booking_status onto the driver's three trip buckets.
/// `pending` returns null — it's a request, not a trip yet.
DriverTripStatus? _statusFromBooking(Booking b) {
  final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
  if (s.contains('reject') || s.contains('cancel')) return DriverTripStatus.cancelled;
  if (b.completedAt != null || s.contains('complete')) return DriverTripStatus.completed;
  if (s.contains('approved')) return DriverTripStatus.active; // incl. CorporateApproved
  return null; // pending → handled as a request on home
}

/// Formats a stored lat/lon pair as a compact coordinate label, or null when
/// either coordinate is missing. The backend booking DTO carries no address
/// text, only coordinates.
String? _locationLabel(double? lat, double? lon) {
  if (lat == null || lon == null) return null;
  return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
}

/// Compact `YYYY-MM-DD HH:MM` from an ISO timestamp, or '' when unparseable.
String _dateLabel(String? iso) {
  final dt = DateTime.tryParse(iso ?? '');
  if (dt == null) return '';
  final l = dt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
}
