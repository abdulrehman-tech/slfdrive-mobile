import '../../../constants/endpoints.dart';
import '../driver/driver_listing_item.dart';
import '../review/review.dart';
import '../vehicle/vehicle.dart';

/// Everything the company profile page needs, from one call:
/// `GET /api/AllCompanies/{id}/profile` (`CompanyProfileDto`).
class CompanyProfile {
  final CompanyInfo company;
  final CompanyStats stats;
  final List<Vehicle> vehicles;
  final List<DriverListingItem> drivers;

  /// Latest active reviews (the backend caps these at 10).
  final List<Review> recentReviews;

  const CompanyProfile({
    required this.company,
    required this.stats,
    required this.vehicles,
    required this.drivers,
    required this.recentReviews,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        (json[key] as List? ?? const []).whereType<Map<String, dynamic>>().map(f).toList();
    return CompanyProfile(
      company: CompanyInfo.fromJson(json['company'] as Map<String, dynamic>? ?? const {}),
      stats: CompanyStats.fromJson(json['stats'] as Map<String, dynamic>? ?? const {}),
      vehicles: list('vehicles', Vehicle.fromJson).where((v) => v.isActive).toList(),
      drivers: list('drivers', DriverListingItem.fromJson),
      recentReviews: list('recentReviews', Review.fromJson).where((r) => r.isActive).toList(),
    );
  }
}

/// Company master record (`AllCompanyDto`), public-facing fields only.
class CompanyInfo {
  final int id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? companyType;
  final String? website;
  final String? contactPhone;
  final String? contactEmail;
  final String? address;
  final int? numberOfBranches;
  final String? logoUrl;

  const CompanyInfo({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.companyType,
    this.website,
    this.contactPhone,
    this.contactEmail,
    this.address,
    this.numberOfBranches,
    this.logoUrl,
  });

  String displayName({bool ar = false}) => (ar && (nameAr?.trim().isNotEmpty ?? false)) ? nameAr!.trim() : name;

  String? get resolvedLogoUrl => ApiEndpoints.resolveMediaUrl(logoUrl);

  static String? _s(Object? v) => (v is String && v.trim().isNotEmpty) ? v.trim() : null;

  factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: _s(json['name']) ?? '',
        nameAr: _s(json['nameAr']),
        description: _s(json['description']),
        companyType: _s(json['companyType']),
        website: _s(json['website']),
        contactPhone: _s(json['contactPhone']),
        contactEmail: _s(json['contactEmail']),
        address: _s(json['address']),
        numberOfBranches: (json['numberOfBranches'] as num?)?.toInt(),
        logoUrl: _s(json['logoUrl']),
      );
}

/// Public stats (`EntityStatsDto`). Earnings/commission are deliberately not
/// modelled: they're business-internal and never shown to customers.
class CompanyStats {
  final double? averageRating;
  final int totalReviews;
  final int completedBookings;

  const CompanyStats({this.averageRating, this.totalReviews = 0, this.completedBookings = 0});

  factory CompanyStats.fromJson(Map<String, dynamic> json) => CompanyStats(
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
        completedBookings: (json['completedBookings'] as num?)?.toInt() ?? 0,
      );
}
