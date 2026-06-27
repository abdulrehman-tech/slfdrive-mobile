/// A selectable location (mst_location row) used in dropdowns — e.g. the
/// driver's base location during profile completion.
class LocationOption {
  final int id;
  final String name;
  final String? nameAr;
  final int? cityId;
  final String? cityName;

  /// Area centre coordinates (from `/api/Location/active`). Used to label a
  /// booking's pickup/dropoff coords with the nearest area name.
  final double? lat;
  final double? lon;

  const LocationOption({
    required this.id,
    required this.name,
    this.nameAr,
    this.cityId,
    this.cityName,
    this.lat,
    this.lon,
  });

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      nameAr: json['nameAr'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
      cityName: json['cityName'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
    );
  }

  /// Display label: "Area, City" when a city is known, else just the area.
  String get label =>
      (cityName != null && cityName!.isNotEmpty) ? '$name, $cityName' : name;
}
