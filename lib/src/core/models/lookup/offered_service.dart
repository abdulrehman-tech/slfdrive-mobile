/// An offered service / vehicle feature lookup (`OfferedServiceDto`) from
/// `/api/OfferedServices/active`. Used to label vehicle features and to filter.
class OfferedService {
  final int id;
  final String name;
  final String? nameAr;
  final int? roleId;
  final bool isActive;
  final String? offerType;

  const OfferedService({
    required this.id,
    required this.name,
    this.nameAr,
    this.roleId,
    this.isActive = true,
    this.offerType,
  });

  String displayName({bool ar = false}) {
    if (ar && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return name;
  }

  factory OfferedService.fromJson(Map<String, dynamic> json) {
    return OfferedService(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      nameAr: json['nameAr'] as String?,
      roleId: (json['roleId'] as num?)?.toInt(),
      isActive: (json['isActive'] as bool?) ?? true,
      offerType: json['offerType'] as String?,
    );
  }
}
