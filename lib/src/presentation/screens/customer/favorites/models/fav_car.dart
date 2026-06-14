class FavCar {
  final String id;
  final String name;
  final String imageUrl;
  final double pricePerDay;
  final String brand;
  final double rating;

  const FavCar({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerDay,
    required this.brand,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'pricePerDay': pricePerDay,
        'brand': brand,
        'rating': rating,
      };

  factory FavCar.fromJson(Map<String, dynamic> json) => FavCar(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0,
        brand: json['brand'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
      );
}
