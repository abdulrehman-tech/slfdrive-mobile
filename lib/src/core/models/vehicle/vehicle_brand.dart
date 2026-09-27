import '../../../constants/endpoints.dart';

/// An active vehicle brand (`VehicleBrandResponseDto`) used for the listing
/// filter chips.
class VehicleBrand {
  final int id;
  final String name;
  final String? nameAr;
  final String? code;

  /// Logo path relative to the media host's `Uploads` (null until uploaded).
  final String? logoUrl;
  final bool isActive;

  const VehicleBrand({
    required this.id,
    required this.name,
    this.nameAr,
    this.code,
    this.logoUrl,
    this.isActive = true,
  });

  String? get resolvedLogoUrl => ApiEndpoints.resolveMediaUrl(logoUrl);

  String displayName({bool ar = false}) {
    if (ar && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return name;
  }

  factory VehicleBrand.fromJson(Map<String, dynamic> json) {
    return VehicleBrand(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      nameAr: json['nameAr'] as String?,
      code: json['code'] as String?,
      logoUrl: json['logoUrl'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }
}
