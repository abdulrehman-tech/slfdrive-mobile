import '../../../constants/endpoints.dart';
import '../../errors/app_exception.dart';
import '../../errors/error_handler.dart';
import '../../models/corporate/corporate_membership.dart';
import '../../network/api_client.dart';

/// Remote reads/writes for the signed-in user's corporate memberships
/// (`/api/CorporateMembership/*`).
abstract class CorporateMembershipRemoteDataSource {
  /// The given user's memberships (`GET /api/CorporateMembership/user/{userId}`).
  Future<List<CorporateMembership>> byUser(int userId);

  /// Applies for (or updates) a corporate membership
  /// (`POST /api/CorporateMembership/apply`). Returns the new membership id.
  Future<int> apply(CorporateMembershipRequest request);
}

class CorporateMembershipRemoteDataSourceImpl
    implements CorporateMembershipRemoteDataSource {
  final ApiClient apiClient;

  CorporateMembershipRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CorporateMembership>> byUser(int userId) async {
    try {
      final res = await apiClient.get(ApiEndpoints.corporateMembershipByUser(userId));
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true) {
        final data = body['data'];
        if (data is! List) return const []; // success + null/empty → no memberships
        return data
            .whereType<Map<String, dynamic>>()
            .map(CorporateMembership.fromJson)
            .toList();
      }
      // isSuccess:false (e.g. backend "Unauthorized") must surface as an error,
      // not masquerade as "no memberships".
      throw AppException(message: _message(body) ?? 'Could not load memberships');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<int> apply(CorporateMembershipRequest request) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.corporateMembershipApply,
        data: request.toJson(),
      );
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true) {
        return (body['data'] as num?)?.toInt() ?? 0;
      }
      throw AppException(message: _message(body) ?? 'Membership application failed');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  String? _message(Map<String, dynamic> body) {
    final m = body['message'];
    if (m is String && m.trim().isNotEmpty) return m;
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
    return null;
  }
}
