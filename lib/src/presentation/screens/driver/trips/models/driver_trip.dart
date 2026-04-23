enum DriverTripStatus { active, completed, cancelled }

class DriverTrip {
  final String id;
  final String customer;
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
    required this.customer,
    required this.destination,
    required this.fare,
    required this.time,
    required this.status,
    this.pickup,
    this.distance,
    this.rating,
    this.reason,
  });
}
