import 'package:flutter/foundation.dart';

import '../data/corporate_membership_mock_data.dart';
import '../data/organizations_mock_data.dart';
import '../models/corporate_membership.dart';
import '../models/membership_status.dart';
import '../models/organization.dart';

/// Owns the current user's corporate membership state and the organization
/// catalogue. Drives both the profile screens and the booking corporate gate.
class CorporateProvider extends ChangeNotifier {
  CorporateProvider({List<Organization>? organizations, List<CorporateMembership>? initial})
    : _organizations = List.unmodifiable(organizations ?? kMockOrganizations),
      _memberships = List<CorporateMembership>.from(initial ?? kInitialMemberships);

  final List<Organization> _organizations;
  final List<CorporateMembership> _memberships;

  List<Organization> get organizations => _organizations;
  List<CorporateMembership> get memberships => List.unmodifiable(_memberships);

  /// Most recent membership (by submittedAt) — drives the headline status.
  CorporateMembership? get latestMembership {
    if (_memberships.isEmpty) return null;
    final sorted = [..._memberships]..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return sorted.first;
  }

  MembershipStatus get effectiveStatus => latestMembership?.status ?? MembershipStatus.notApplied;

  /// Orgs the user is currently approved for (used by the booking step picker).
  List<Organization> get approvedOrganizations {
    final approvedIds = _memberships
        .where((m) => m.status == MembershipStatus.approved)
        .map((m) => m.organizationId)
        .toSet();
    return _organizations.where((o) => approvedIds.contains(o.id)).toList();
  }

  Organization? organizationById(String id) {
    for (final o in _organizations) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Submit a new application — appended in `pending` state. Async to mimic
  /// network latency.
  Future<void> submitApplication({
    required String organizationId,
    required String employeeId,
    required String position,
    required String department,
    required String workEmail,
    required DateTime joinDate,
    required String managerName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final m = CorporateMembership(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      organizationId: organizationId,
      employeeId: employeeId,
      position: position,
      department: department,
      workEmail: workEmail,
      joinDate: joinDate,
      managerName: managerName,
      status: MembershipStatus.pending,
      submittedAt: DateTime.now(),
    );
    _memberships.add(m);
    notifyListeners();
  }

  /// QA helper — flips a pending membership to approved.
  void simulateApproval(String membershipId) {
    final idx = _memberships.indexWhere((m) => m.id == membershipId);
    if (idx == -1) return;
    _memberships[idx] = _memberships[idx].copyWith(
      status: MembershipStatus.approved,
      reviewedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// QA helper — flips a pending membership to rejected.
  void simulateRejection(String membershipId, {String reason = 'Insufficient verification'}) {
    final idx = _memberships.indexWhere((m) => m.id == membershipId);
    if (idx == -1) return;
    _memberships[idx] = _memberships[idx].copyWith(
      status: MembershipStatus.rejected,
      reviewedAt: DateTime.now(),
      rejectionReason: reason,
    );
    notifyListeners();
  }
}
