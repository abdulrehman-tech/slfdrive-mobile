import '../../../constants/endpoints.dart';
import '../../errors/app_exception.dart';
import '../../errors/error_handler.dart';
import '../../models/company/company_profile.dart';
import '../../network/api_client.dart';
import 'promo_code_remote_data_source.dart' show localizedMessage;

/// Rental company reads (`/api/AllCompanies/*`).
abstract class CompanyRemoteDataSource {
  /// Full profile: info, stats, vehicles, drivers and recent reviews.
  Future<CompanyProfile> profile(int companyId);

  /// Every active company (rental and corporate) with its logo — the only
  /// source of logos for screens whose DTOs carry just a company id.
  Future<List<CompanyInfo>> active();
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final ApiClient apiClient;

  CompanyRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CompanyProfile> profile(int companyId) async {
    try {
      final res = await apiClient.get(ApiEndpoints.companyProfile(companyId));
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return CompanyProfile.fromJson(body['data'] as Map<String, dynamic>);
      }
      throw AppException(message: localizedMessage(body) ?? 'company_load_failed');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<CompanyInfo>> active() async {
    try {
      final res = await apiClient.get(ApiEndpoints.activeAllCompanies);
      final data = (res.data as Map<String, dynamic>)['data'];
      if (data is! List) return const [];
      return data.whereType<Map<String, dynamic>>().map(CompanyInfo.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
