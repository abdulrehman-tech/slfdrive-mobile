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
  });
}
