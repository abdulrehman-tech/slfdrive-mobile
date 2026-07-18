/// Driver record returned by `GET /api/Driver/{id}` (DriverResponseDto). Used to
/// refresh the dashboard with the server's current verification status, photo,
/// and profile fields without requiring a re-login.
class DriverDetails {
  final int id;
  /// The driver entity's own id — what `Booking/create` expects as `driverId`
  /// (distinct from the response row [id]).
  final int? driverId;
  final String? fullName;
  final String? fullNameAr;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isVerified;
  final bool isActive;
  final String? licenceNumber;
  final String? carPlateNumber;
  final String? locationName;
  final String? languagesKnown;
  final int? yearsOfExperience;
  final double? amountPerDay;
  final double? amountPerHour;
  final bool? hasVehicle;
  final String? gender;
  final String? dateOfBirth;
  final String? preferredLang;
  final String? civilIdUrlF;
  final String? civilIdUrlB;
  final String? licenceExpiryDate;
  final int? locationId;
  final double? lat;
  final double? lon;
  final int? allCompanyId;
  /// Server-side availability flag (`is_online` on `mst_driver`); null when the
  /// driver never toggled it (treated as offline). Seeds the home toggle.
  final bool? isOnline;

  const DriverDetails({
    required this.id,
    this.driverId,
    this.fullName,
    this.fullNameAr,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.isVerified = false,
    this.isActive = false,
    this.licenceNumber,
    this.carPlateNumber,
    this.locationName,
    this.languagesKnown,
    this.yearsOfExperience,
    this.amountPerDay,
    this.amountPerHour,
    this.hasVehicle,
    this.gender,
    this.dateOfBirth,
    this.preferredLang,
    this.civilIdUrlF,
    this.civilIdUrlB,
    this.licenceExpiryDate,
    this.locationId,
    this.lat,
    this.lon,
    this.allCompanyId,
    this.isOnline,
  });

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      id: (json['id'] as num?)?.toInt() ?? 0,
      driverId: (json['driverId'] as num?)?.toInt(),
      fullName: json['fullName'] as String?,
      fullNameAr: json['fullNameAr'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isVerified: (json['isVerified'] as bool?) ?? false,
      isActive: (json['isActive'] as bool?) ?? false,
      licenceNumber: json['liscenceNumber'] as String?,
      carPlateNumber: json['carPlateNumber'] as String?,
      locationName: json['locationName'] as String?,
      languagesKnown: json['languagesKnown'] as String?,
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
      amountPerDay: (json['amountPerDay'] as num?)?.toDouble(),
      amountPerHour: (json['amountPerHour'] as num?)?.toDouble(),
      hasVehicle: json['hasVehicle'] as bool?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      preferredLang: json['preferredLang'] as String?,
      civilIdUrlF: json['civilIdUrlF'] as String?,
      civilIdUrlB: json['civilIdUrlB'] as String?,
      licenceExpiryDate: json['liscenceExpiryDate'] as String?,
      locationId: (json['locationId'] as num?)?.toInt(),
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      allCompanyId: (json['allCompanyId'] as num?)?.toInt(),
      isOnline: json['isOnline'] as bool?,
    );
  }
}
