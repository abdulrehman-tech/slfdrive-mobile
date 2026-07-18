class SearchResultDriver {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int trips;
  final String speciality;
  final double pricePerDay;

  /// Live presence — drives the green/grey dot on the search result card.
  final bool isOnline;

  const SearchResultDriver({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.trips,
    required this.speciality,
    required this.pricePerDay,
    this.isOnline = false,
  });
}
