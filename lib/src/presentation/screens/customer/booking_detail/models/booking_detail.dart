enum BookingTimelineStage { confirmed, pickedUp, inTrip, returned }

class BookingDetail {
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
}
