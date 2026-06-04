/// A selectable location (mst_location row) used in dropdowns — e.g. the
/// driver's base location during profile completion.
class LocationOption {
  final int id;
  final String name;
  final String? nameAr;
  final int? cityId;
  final String? cityName;

  const LocationOption({
    required this.id,
    required this.name,
    this.nameAr,
    this.cityId,
    this.cityName,
  });

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      nameAr: json['nameAr'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
      cityName: json['cityName'] as String?,
    );
  }
}
