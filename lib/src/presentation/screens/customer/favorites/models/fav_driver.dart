class FavDriver {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int trips;
  final String speciality;

  const FavDriver({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.trips,
    required this.speciality,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'rating': rating,
        'trips': trips,
        'speciality': speciality,
      };

  factory FavDriver.fromJson(Map<String, dynamic> json) => FavDriver(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        trips: (json['trips'] as num?)?.toInt() ?? 0,
        speciality: json['speciality'] as String? ?? '',
      );
}
