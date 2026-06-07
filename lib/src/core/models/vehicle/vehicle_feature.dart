/// A feature/offered-service attached to a vehicle (`VehicleFeatureDto`).
class VehicleFeature {
  final int id;
  final int vehicleId;
  final int offeredServiceId;
  final String? serviceName;
  final String? serviceNameAr;

  const VehicleFeature({
    required this.id,
    required this.vehicleId,
    required this.offeredServiceId,
    this.serviceName,
    this.serviceNameAr,
  });

  factory VehicleFeature.fromJson(Map<String, dynamic> json) {
    return VehicleFeature(
      id: (json['id'] as num?)?.toInt() ?? 0,
      vehicleId: (json['vehicleId'] as num?)?.toInt() ?? 0,
      offeredServiceId: (json['offeredServiceId'] as num?)?.toInt() ?? 0,
      serviceName: json['serviceName'] as String?,
      serviceNameAr: json['serviceNameAr'] as String?,
    );
  }
}
