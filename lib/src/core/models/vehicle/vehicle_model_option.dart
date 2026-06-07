/// An active vehicle model (`VehicleModelResponseDto`), optionally scoped to a
/// brand. Named `*Option` to avoid clashing with the `Vehicle` entity / the
/// Flutter "model" term.
class VehicleModelOption {
  final int id;
  final String name;
  final String? nameAr;
  final String? code;
  final bool isActive;
  final int brandId;
  final String? brandName;
  final String? brandNameAr;

  const VehicleModelOption({
    required this.id,
    required this.name,
    this.nameAr,
    this.code,
    this.isActive = true,
    required this.brandId,
    this.brandName,
    this.brandNameAr,
  });

  String displayName({bool ar = false}) {
    if (ar && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return name;
  }

  factory VehicleModelOption.fromJson(Map<String, dynamic> json) {
    return VehicleModelOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      nameAr: json['nameAr'] as String?,
      code: json['code'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      brandId: (json['brandId'] as num?)?.toInt() ?? 0,
      brandName: json['brandName'] as String?,
      brandNameAr: json['brandNameAr'] as String?,
    );
  }
}
