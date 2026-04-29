import '../models/corporate_membership.dart';

/// Initial state of the current user's corporate memberships.
///
/// Defaults to empty (status = notApplied). Flip the entries below to one of
/// the provided seed records to demo each state without touching backend code:
///
///   * [kSeedPendingMembership] — fresh application awaiting review
///   * [kSeedApprovedMembership] — active employee at Mwasalat
///   * [kSeedRejectedMembership] — application rejected with reason
const List<CorporateMembership> kInitialMemberships = <CorporateMembership>[];
