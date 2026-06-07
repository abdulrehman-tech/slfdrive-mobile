import '../../../../../core/models/vehicle/vehicle.dart';

/// Lightweight view model for a car row in the listing screen.
class CarItem {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double pricePerDay;

  /// Aggregate rating. Null when the backend has no rating yet (reviews are
  /// booking-scoped with no per-vehicle aggregate) — the UI shows a "New"
  /// placeholder instead of a star value.
  final double? rating;
  final int seats;
  final String transmission;
  final String fuelType;
  final bool isAvailable;

  const CarItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.pricePerDay,
    this.rating,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    this.isAvailable = true,
  });

  /// Maps a backend [Vehicle] into the listing view model. [ar] selects the
  /// Arabic resolved names when true.
  factory CarItem.fromVehicle(Vehicle v, {bool ar = false}) {
    return CarItem(
      id: v.id.toString(),
      name: v.displayTitle(ar: ar),
      brand: (ar ? (v.brandNameAr ?? v.brandName) : v.brandName) ?? '',
      imageUrl: v.primaryPhoto ?? '',
      pricePerDay: v.pricePerDay ?? 0,
      rating: v.rating,
      seats: v.seats ?? 0,
      transmission: (ar ? (v.transmissionTypeNameAr ?? v.transmissionTypeName) : v.transmissionTypeName) ?? '—',
      fuelType: (ar ? (v.fuelTypeNameAr ?? v.fuelTypeName) : v.fuelTypeName) ?? '—',
      isAvailable: v.isActive,
    );
  }
}
