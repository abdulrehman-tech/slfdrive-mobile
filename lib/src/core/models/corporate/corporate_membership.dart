/// A corporate-membership record returned by `GET /api/CorporateMembership/my`
/// (`SLF.Domain.DTOs.CorporateMembershipResponseDto`). Ties the signed-in user
/// to a corporate company (`allCompanyId`) with an approval `status`.
class CorporateMembership {
  final int id;
  final int userId;
  final int allCompanyId;
  final String? companyName;
  final String? companyNameAr;
  final String? status;
  final bool isActive;
  final String? rejectReason;
  final String? employeeId;
  final String? designation;
  final String? department;
  final String? officeAddress;
  final String? officeNumber;
  final String? managerName;
  final String? approvedByName;
  final String? approvedAt;
  final String? createdAt;

  const CorporateMembership({
    required this.id,
    required this.userId,
    required this.allCompanyId,
    this.companyName,
    this.companyNameAr,
    this.status,
    this.isActive = false,
    this.rejectReason,
    this.employeeId,
    this.designation,
    this.department,
    this.officeAddress,
    this.officeNumber,
    this.managerName,
    this.approvedByName,
    this.approvedAt,
    this.createdAt,
  });

  String get statusLower => (status ?? '').toLowerCase();

  /// Eligible to back a corporate booking: approved by the company and active.
  bool get isApprovedActive => isActive && statusLower == 'approved';
  bool get isPending => statusLower == 'pending' || statusLower.isEmpty;
  bool get isRejected => statusLower == 'rejected';

  /// Localized-or-fallback display name for the company.
  String displayCompanyName() {
    final n = (companyName ?? '').trim();
    if (n.isNotEmpty) return n;
    final ar = (companyNameAr ?? '').trim();
    if (ar.isNotEmpty) return ar;
    return 'SLF$allCompanyId';
  }

  factory CorporateMembership.fromJson(Map<String, dynamic> json) {
    int i(String k) => (json[k] as num?)?.toInt() ?? 0;
    return CorporateMembership(
      id: i('id'),
      userId: i('userId'),
      allCompanyId: i('allCompanyId'),
      companyName: json['companyName'] as String?,
      companyNameAr: json['companyNameAr'] as String?,
      status: json['status'] as String?,
      isActive: json['isActive'] == true,
      rejectReason: json['rejectReason'] as String?,
      employeeId: json['employeeId'] as String?,
      designation: json['designation'] as String?,
      department: json['department'] as String?,
      officeAddress: json['officeAddress'] as String?,
      officeNumber: json['officeNumber'] as String?,
      managerName: json['managerName'] as String?,
      approvedByName: json['approvedByName'] as String?,
      approvedAt: json['approvedAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

/// Apply/update body for `POST /api/CorporateMembership/apply`
/// (`SLF.Domain.DTOs.CorporateMembershipRequestDto`). Only [allCompanyId] is
/// required; the rest are optional employment details.
class CorporateMembershipRequest {
  final int? id;
  final int allCompanyId;
  final String? employeeId;
  final String? designation;
  final String? department;
  final String? officeAddress;
  final String? officeNumber;
  final String? managerName;

  const CorporateMembershipRequest({
    this.id,
    required this.allCompanyId,
    this.employeeId,
    this.designation,
    this.department,
    this.officeAddress,
    this.officeNumber,
    this.managerName,
  });

  Map<String, dynamic> toJson() {
    String? clean(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    return {
      if (id != null) 'id': id,
      'allCompanyId': allCompanyId,
      'employeeId': clean(employeeId),
      'designation': clean(designation),
      'department': clean(department),
      'officeAddress': clean(officeAddress),
      'officeNumber': clean(officeNumber),
      'managerName': clean(managerName),
    };
  }
}
