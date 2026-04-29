import 'membership_status.dart';

/// One application/membership record tying the current customer to an
/// organization. The latest record (by submittedAt) drives the
/// "effective" status surfaced in profile + booking gates.
class CorporateMembership {
  final String id;
  final String organizationId;
  final String employeeId;
  final String position;
  final String department;
  final String workEmail;
  final DateTime joinDate;
  final String managerName;
  final MembershipStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  const CorporateMembership({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.position,
    required this.department,
    required this.workEmail,
    required this.joinDate,
    required this.managerName,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  CorporateMembership copyWith({
    MembershipStatus? status,
    DateTime? reviewedAt,
    String? rejectionReason,
  }) =>
      CorporateMembership(
        id: id,
        organizationId: organizationId,
        employeeId: employeeId,
        position: position,
        department: department,
        workEmail: workEmail,
        joinDate: joinDate,
        managerName: managerName,
        status: status ?? this.status,
        submittedAt: submittedAt,
        reviewedAt: reviewedAt ?? this.reviewedAt,
        rejectionReason: rejectionReason ?? this.rejectionReason,
      );
}
