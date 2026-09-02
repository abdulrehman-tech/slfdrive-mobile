import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../network/api_client.dart';

/// Remote write for this device's Firebase token (`PUT /api/Auth/fcm-token`).
///
/// The endpoint is JWT-protected; [ApiClient]'s auth interceptor attaches the
/// bearer automatically, and the backend takes the user identity from the token
/// rather than the body. There is no matching read or delete endpoint.
abstract class PushRemoteDataSource {
  /// Registers or updates the token. Returns the envelope so the repository can
  /// decide how loud to be about a failure.
  Future<bool> registerFcmToken({
    required String deviceId,
    required String platform,
    required String fcmToken,
  });
}

class PushRemoteDataSourceImpl implements PushRemoteDataSource {
  final ApiClient apiClient;

  PushRemoteDataSourceImpl(this.apiClient);

  @override
  Future<bool> registerFcmToken({
    required String deviceId,
    required String platform,
    required String fcmToken,
  }) async {
    try {
      // Exactly these three keys — the schema is `additionalProperties: false`.
      final res = await apiClient.put(
        ApiEndpoints.fcmToken,
        data: {
          'deviceId': deviceId,
          'platform': platform,
          'fcmToken': fcmToken,
        },
      );
      final body = res.data;
      return body is Map<String, dynamic> && body['isSuccess'] == true;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
