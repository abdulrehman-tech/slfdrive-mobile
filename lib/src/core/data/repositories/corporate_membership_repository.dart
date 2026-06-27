import '../../models/corporate/corporate_membership.dart';
import '../datasources/corporate_membership_remote_data_source.dart';

/// Corporate-membership reads/writes for the signed-in user.
abstract class CorporateMembershipRepository {
  Future<List<CorporateMembership>> byUser(int userId);
  Future<int> apply(CorporateMembershipRequest request);
}

class CorporateMembershipRepositoryImpl implements CorporateMembershipRepository {
  final CorporateMembershipRemoteDataSource remote;

  CorporateMembershipRepositoryImpl(this.remote);

  @override
  Future<List<CorporateMembership>> byUser(int userId) => remote.byUser(userId);

  @override
  Future<int> apply(CorporateMembershipRequest request) => remote.apply(request);
}
