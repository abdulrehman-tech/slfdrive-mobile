/// Authenticated user, matching the `data.user` object returned by the auth
/// endpoints (login-mobile / verify-otp / refresh).
class User {
  final int id;
  final String? email;
  final String? phoneNumber;
  final int? roleId;
  final String? roleName;
  final String? roleNameAr;
  final String? fullName;
  final String? fullNameAr;
  final bool? isActive;
  final bool? isVerified;
  final String? photoUrl;
  final String? preferredLang;
  final String? gender;
  final String? civilIdUrlF;
  final String? civilIdUrlB;
  final int? companyId;
  final String? companyName;
  final String? companyNameAr;
  final String? dateOfBirth;

  const User({
    required this.id,
    this.email,
    this.phoneNumber,
    this.roleId,
    this.roleName,
    this.roleNameAr,
    this.fullName,
    this.fullNameAr,
    this.isActive,
    this.isVerified,
    this.photoUrl,
    this.preferredLang,
    this.gender,
    this.civilIdUrlF,
    this.civilIdUrlB,
    this.companyId,
    this.companyName,
    this.companyNameAr,
    this.dateOfBirth,
  });

  /// True when the backend role identifies a driver (roleId 2 / roleName
  /// "Driver"). Used to set the local [UserRole] after login.
  bool get isDriver =>
      roleId == 2 || (roleName?.toLowerCase() == 'driver');

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      roleId: (json['roleId'] as num?)?.toInt(),
      roleName: json['roleName'] as String?,
      roleNameAr: json['roleNameAr'] as String?,
      fullName: json['fullName'] as String?,
      fullNameAr: json['fullNameAr'] as String?,
      isActive: json['isActive'] as bool?,
      isVerified: json['isVerified'] as bool?,
      photoUrl: json['photoUrl'] as String?,
      preferredLang: json['preferredLang'] as String?,
      gender: json['gender'] as String?,
      civilIdUrlF: json['civilIdUrlF'] as String?,
      civilIdUrlB: json['civilIdUrlB'] as String?,
      companyId: (json['companyId'] as num?)?.toInt(),
      companyName: json['companyName'] as String?,
      companyNameAr: json['companyNameAr'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phoneNumber': phoneNumber,
        'roleId': roleId,
        'roleName': roleName,
        'roleNameAr': roleNameAr,
        'fullName': fullName,
        'fullNameAr': fullNameAr,
        'isActive': isActive,
        'isVerified': isVerified,
        'photoUrl': photoUrl,
        'preferredLang': preferredLang,
        'gender': gender,
        'civilIdUrlF': civilIdUrlF,
        'civilIdUrlB': civilIdUrlB,
        'companyId': companyId,
        'companyName': companyName,
        'companyNameAr': companyNameAr,
        'dateOfBirth': dateOfBirth,
      };
}
