/// A single row from `GeneralType`/`GeneralStatus` lookups
/// (`GeneralTypeResponseDto` / `GeneralStatusResponseDto`). These drive the
/// `serviceTypeId` / `paymentTypeId` / `bookingTypeId` / status ids required by
/// booking creation, resolved at runtime instead of hardcoded.
class GeneralLookup {
  final int id;
  final String? name;
  final String? nameAr;
  final String? type;
  final bool isActive;

  const GeneralLookup({
    required this.id,
    this.name,
    this.nameAr,
    this.type,
    this.isActive = true,
  });

  factory GeneralLookup.fromJson(Map<String, dynamic> json) {
    return GeneralLookup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String?,
      nameAr: json['nameAr'] as String?,
      type: json['type'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }
}
