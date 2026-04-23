class TripRequest {
  final String id;
  final String customer;
  final String pickup;
  final String destination;
  final String distance;
  final double fare;
  final String time;

  const TripRequest({
    required this.id,
    required this.customer,
    required this.pickup,
    required this.destination,
    required this.distance,
    required this.fare,
    required this.time,
  });
}
