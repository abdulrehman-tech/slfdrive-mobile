import '../../../constants/endpoints.dart';

/// A corporate company the customer can book under (`AllCompanyDto`,
/// `GET /api/AllCompanies/active`). Its [id] is the `corporateCompanyId` sent
/// on booking creation.
class AllCompany {
  final int id;
  final String? name;
  final String? nameAr;
  final String? companyType;
  final String? address;
  final String? logoUrl;

  const AllCompany({
    required this.id,
    this.name,
    this.nameAr,
    this.companyType,
    this.address,
    this.logoUrl,
  });

  String displayName({bool ar = false}) {
    if (ar && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return (name != null && name!.isNotEmpty) ? name! : 'Company';
  }

  String? get resolvedLogoUrl => ApiEndpoints.resolveMediaUrl(logoUrl);

  factory AllCompany.fromJson(Map<String, dynamic> json) {
    return AllCompany(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String?,
      nameAr: json['nameAr'] as String?,
      companyType: json['companyType'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
