class SearchResultCar {
  final String id;
  final String name;
  final String imageUrl;
  final double pricePerDay;
  final String brand;
  final double rating;
  final String transmission;
  final int seats;
  final String fuelType;

  const SearchResultCar({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerDay,
    required this.brand,
    required this.rating,
    required this.transmission,
    required this.seats,
    required this.fuelType,
  });
}
