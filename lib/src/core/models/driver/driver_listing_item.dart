import '../../../constants/endpoints.dart';

/// A driver as shown in the customer-facing driver listing
/// (`DriverResponseDto`). Distinct from `DriverDetails`, which backs the
/// driver's own dashboard.
///
/// [rating] is nullable and currently always null — reviews are booking-scoped
/// on the backend with no per-driver aggregate yet. See [Vehicle] for the same
/// note; the listing UI handles a null rating.
class DriverListingItem {
  final int id;
  final int? driverId;
  final String? fullName;
  final String? fullNameAr;
  final String? photoUrl;
  final int? yearsOfExperience;
  final double? amountPerDay;
  final double? amountPerHour;
  final String? languagesKnown;
  final int? locationId;
  final String? locationName;
  final String? locationNameAr;
  final bool hasVehicle;
  final bool isVerified;
  final bool isActive;
  final double? lat;
  final double? lon;
  final double? distanceKm;
  final double? rating;

  const DriverListingItem({
    required this.id,
    this.driverId,
    this.fullName,
    this.fullNameAr,
    this.photoUrl,
    this.yearsOfExperience,
    this.amountPerDay,
    this.amountPerHour,
    this.languagesKnown,
    this.locationId,
    this.locationName,
    this.locationNameAr,
    this.hasVehicle = false,
    this.isVerified = false,
    this.isActive = true,
    this.lat,
    this.lon,
    this.distanceKm,
    this.rating,
  });

  String displayName({bool ar = false}) {
    if (ar && fullNameAr != null && fullNameAr!.isNotEmpty) return fullNameAr!;
    return (fullName != null && fullName!.isNotEmpty) ? fullName! : 'Driver';
  }

  String? get resolvedPhotoUrl => ApiEndpoints.resolveMediaUrl(photoUrl);

  factory DriverListingItem.fromJson(Map<String, dynamic> json) {
    return DriverListingItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      driverId: (json['driverId'] as num?)?.toInt(),
      fullName: json['fullName'] as String?,
      fullNameAr: json['fullNameAr'] as String?,
      photoUrl: json['photoUrl'] as String?,
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
      amountPerDay: (json['amountPerDay'] as num?)?.toDouble(),
      amountPerHour: (json['amountPerHour'] as num?)?.toDouble(),
      languagesKnown: json['languagesKnown'] as String?,
      locationId: (json['locationId'] as num?)?.toInt(),
      locationName: json['locationName'] as String?,
      locationNameAr: json['locationNameAr'] as String?,
      hasVehicle: (json['hasVehicle'] as bool?) ?? false,
      isVerified: (json['isVerified'] as bool?) ?? false,
      isActive: (json['isActive'] as bool?) ?? true,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}
