/// Lightweight view model for a car row in the listing screen.
class CarItem {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double pricePerDay;
  final double rating;
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
    required this.rating,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    this.isAvailable = true,
  });
}
