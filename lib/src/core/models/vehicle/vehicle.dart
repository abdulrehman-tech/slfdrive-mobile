import '../../../constants/endpoints.dart';
import 'vehicle_feature.dart';

/// A rental vehicle returned by the `/api/Vehicle/*` endpoints
/// (`VehicleResponseDto`). Photo URLs are resolved to absolute URLs.
///
/// [rating] is intentionally nullable and currently always null: the backend
/// exposes reviews per-booking only (`/api/Review/booking/{id}/average`), with
/// no per-vehicle aggregate. Once an aggregate endpoint/field exists, populate
/// this from it — the listing UI already handles a null rating.
class Vehicle {
  final int id;
  final int ownerUserId;
  final int brandId;
  final int modelId;
  final int? branchId;
  final int? locationId;
  final String? name;
  final int? year;
  final String? color;
  final String? plateNumber;
  final int? vehicleTypeId;
  final int? transmissionTypeId;
  final int? fuelType;
  final int? seats;
  final double? pricePerDay;
  final double? pricePerHour;
  final List<String> photoUrls;
  final int? statusId;
  final bool isActive;
  final double? lat;
  final double? lon;
  final String? mileage;
  final double? distanceKm;

  // Resolved lookup names (EN + AR)
  final String? ownerName;
  final int? companyId;
  final String? companyName;
  final String? companyNameAr;
  final String? brandName;
  final String? brandNameAr;
  final String? modelName;
  final String? modelNameAr;
  final String? locationName;
  final String? locationNameAr;
  final String? vehicleTypeName;
  final String? vehicleTypeNameAr;
  final String? transmissionTypeName;
  final String? transmissionTypeNameAr;
  final String? fuelTypeName;
  final String? fuelTypeNameAr;
  final String? statusName;
  final String? statusNameAr;

  final List<VehicleFeature> features;

  /// Aggregate rating — see class doc. Null until the backend provides it.
  final double? rating;

  const Vehicle({
    required this.id,
    required this.ownerUserId,
    required this.brandId,
    required this.modelId,
    this.branchId,
    this.locationId,
    this.name,
    this.year,
    this.color,
    this.plateNumber,
    this.vehicleTypeId,
    this.transmissionTypeId,
    this.fuelType,
    this.seats,
    this.pricePerDay,
    this.pricePerHour,
    this.photoUrls = const [],
    this.statusId,
    this.isActive = true,
    this.lat,
    this.lon,
    this.mileage,
    this.distanceKm,
    this.ownerName,
    this.companyId,
    this.companyName,
    this.companyNameAr,
    this.brandName,
    this.brandNameAr,
    this.modelName,
    this.modelNameAr,
    this.locationName,
    this.locationNameAr,
    this.vehicleTypeName,
    this.vehicleTypeNameAr,
    this.transmissionTypeName,
    this.transmissionTypeNameAr,
    this.fuelTypeName,
    this.fuelTypeNameAr,
    this.statusName,
    this.statusNameAr,
    this.features = const [],
    this.rating,
  });

  /// Brand + model as a display title, e.g. "Mercedes AMG GT". Falls back to
  /// [name] / brand alone when parts are missing.
  String displayTitle({bool ar = false}) {
    final brand = (ar ? brandNameAr : brandName) ?? brandName;
    final model = (ar ? modelNameAr : modelName) ?? modelName;
    final parts = [
      if (brand != null && brand.isNotEmpty) brand,
      if (model != null && model.isNotEmpty) model,
    ];
    if (parts.isNotEmpty) return parts.join(' ');
    return (name != null && name!.isNotEmpty) ? name! : 'Vehicle';
  }

  String? get primaryPhoto => photoUrls.isNotEmpty ? photoUrls.first : null;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photoUrls'];
    final photos = rawPhotos is List
        ? rawPhotos
            .map((e) => ApiEndpoints.resolveMediaUrl(e as String?))
            .whereType<String>()
            .toList()
        : <String>[];
    final rawFeatures = json['features'];
    final features = rawFeatures is List
        ? rawFeatures
            .whereType<Map<String, dynamic>>()
            .map(VehicleFeature.fromJson)
            .toList()
        : <VehicleFeature>[];
    return Vehicle(
      id: (json['id'] as num?)?.toInt() ?? 0,
      ownerUserId: (json['ownerUserId'] as num?)?.toInt() ?? 0,
      brandId: (json['brandId'] as num?)?.toInt() ?? 0,
      modelId: (json['modelId'] as num?)?.toInt() ?? 0,
      branchId: (json['branchId'] as num?)?.toInt(),
      locationId: (json['locationId'] as num?)?.toInt(),
      name: json['name'] as String?,
      year: (json['year'] as num?)?.toInt(),
      color: json['color'] as String?,
      plateNumber: json['plateNumber'] as String?,
      vehicleTypeId: (json['vehicleTypeId'] as num?)?.toInt(),
      transmissionTypeId: (json['transmissionTypeId'] as num?)?.toInt(),
      fuelType: (json['fuelType'] as num?)?.toInt(),
      seats: (json['seats'] as num?)?.toInt(),
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
      photoUrls: photos,
      statusId: (json['statusId'] as num?)?.toInt(),
      isActive: (json['isActive'] as bool?) ?? true,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      mileage: json['mileage'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      ownerName: json['ownerName'] as String?,
      companyId: (json['companyId'] as num?)?.toInt(),
      companyName: json['companyName'] as String?,
      companyNameAr: json['companyNameAr'] as String?,
      brandName: json['brandName'] as String?,
      brandNameAr: json['brandNameAr'] as String?,
      modelName: json['modelName'] as String?,
      modelNameAr: json['modelNameAr'] as String?,
      locationName: json['locationName'] as String?,
      locationNameAr: json['locationNameAr'] as String?,
      vehicleTypeName: json['vehicleTypeName'] as String?,
      vehicleTypeNameAr: json['vehicleTypeNameAr'] as String?,
      transmissionTypeName: json['transmissionTypeName'] as String?,
      transmissionTypeNameAr: json['transmissionTypeNameAr'] as String?,
      fuelTypeName: json['fuelTypeName'] as String?,
      fuelTypeNameAr: json['fuelTypeNameAr'] as String?,
      statusName: json['statusName'] as String?,
      statusNameAr: json['statusNameAr'] as String?,
      features: features,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}
