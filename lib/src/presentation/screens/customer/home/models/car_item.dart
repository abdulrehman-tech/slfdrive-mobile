import '../../../../../core/models/vehicle/vehicle.dart';

/// Home-screen featured car view model. Carries the extra fields that
/// [CarCard] renders (horsepower, transmission, seats, tag, isFavourite) that
/// the car-listing screen's leaner [CarItem] omits.
///
/// [rating] is nullable — the backend currently returns null per-vehicle.
/// [CarCard] renders a "New" placeholder when null.
class CarItem {
  final String id;
  final String name;
  final String imageUrl;
  final double pricePerDay;
  final int horsepower;
  final String transmission;
  final int seats;
  final String tag;
  bool isFavourite;

  /// Aggregate vehicle rating. Null when the backend has no rating yet.
  final double? rating;

  CarItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerDay,
    required this.horsepower,
    required this.transmission,
    required this.seats,
    this.tag = '',
    this.isFavourite = false,
    this.rating,
  });

  /// Maps a backend [Vehicle] to a home CarItem. [ar] selects Arabic names.
  factory CarItem.fromVehicle(Vehicle v, {bool ar = false}) {
    return CarItem(
      id: v.id.toString(),
      name: v.displayTitle(ar: ar),
      imageUrl: v.primaryPhoto ?? '',
      pricePerDay: v.pricePerDay ?? 0,
      // The backend does not surface horsepower; default to 0 so the spec pill
      // is hidden when zero (or the card can choose not to render it).
      horsepower: 0,
      transmission: (ar ? (v.transmissionTypeNameAr ?? v.transmissionTypeName) : v.transmissionTypeName) ?? '—',
      seats: v.seats ?? 0,
      tag: '',
      isFavourite: false,
      rating: v.rating,
    );
  }
}
