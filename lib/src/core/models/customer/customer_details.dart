/// Customer record returned by `GET /api/Customer/{id}` (CustomerResponseDto).
/// Used to refresh the cached profile (name, email, photo) on pull-to-refresh.
class CustomerDetails {
  final int id;
  final String? fullName;
  final String? fullNameAr;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isActive;
  final String? gender;
  final String? dateOfBirth;
  final String? preferredLang;
  final String? civilIdUrlF;
  final String? civilIdUrlB;
  final double? lat;
  final double? lon;

  const CustomerDetails({
    required this.id,
    this.fullName,
    this.fullNameAr,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.isActive = false,
    this.gender,
    this.dateOfBirth,
    this.preferredLang,
    this.civilIdUrlF,
    this.civilIdUrlB,
    this.lat,
    this.lon,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['fullName'] as String?,
      fullNameAr: json['fullNameAr'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isActive: (json['isActive'] as bool?) ?? false,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      preferredLang: json['preferredLang'] as String?,
      civilIdUrlF: json['civilIdUrlF'] as String?,
      civilIdUrlB: json['civilIdUrlB'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
    );
  }
}
