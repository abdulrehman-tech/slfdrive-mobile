import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/app/app_version_info.dart';
import '../../network/api_client.dart';

/// Remote read for the published app version (`/api/app-version/*`).
abstract class AppVersionRemoteDataSource {
  /// Latest version row for [appName]
  /// (`GET /api/app-version/check/{appName}`), or null when none.
  Future<AppVersionInfo?> check(String appName);
}

class AppVersionRemoteDataSourceImpl implements AppVersionRemoteDataSource {
  final ApiClient apiClient;

  AppVersionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AppVersionInfo?> check(String appName) async {
    try {
      final res = await apiClient.get(ApiEndpoints.appVersionCheck(appName));
      final body = res.data;
      if (body is Map<String, dynamic> && body['isSuccess'] == true && body['data'] is Map) {
        return AppVersionInfo.fromJson(Map<String, dynamic>.from(body['data'] as Map));
      }
      return null;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
