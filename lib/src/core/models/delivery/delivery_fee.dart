/// A delivery fee for a (company, area) pair (`DeliveryFeeResponseDto`,
/// `GET /api/DeliveryFee/*`). [fee] is the amount in OMR charged to deliver a
/// vehicle to the area identified by [locationId].
class DeliveryFee {
  final int id;
  final int companyId;
  final int locationId;
  final double fee;
  final String? notes;
  final bool isActive;
  final String? companyName;
  final String? companyNameAr;
  final String? locationName;
  final String? locationNameAr;
  final int? cityId;
  final String? cityName;

  const DeliveryFee({
    required this.id,
    required this.companyId,
    required this.locationId,
    required this.fee,
    this.notes,
    this.isActive = true,
    this.companyName,
    this.companyNameAr,
    this.locationName,
    this.locationNameAr,
    this.cityId,
    this.cityName,
  });

  factory DeliveryFee.fromJson(Map<String, dynamic> json) {
    return DeliveryFee(
      id: (json['id'] as num?)?.toInt() ?? 0,
      companyId: (json['companyId'] as num?)?.toInt() ?? 0,
      locationId: (json['locationId'] as num?)?.toInt() ?? 0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      isActive: json['isActive'] == true,
      companyName: json['companyName'] as String?,
      companyNameAr: json['companyNameAr'] as String?,
      locationName: json['locationName'] as String?,
      locationNameAr: json['locationNameAr'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
      cityName: json['cityName'] as String?,
    );
  }
}
