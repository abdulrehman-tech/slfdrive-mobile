import 'package:flutter/foundation.dart';

import '../datasources/push_remote_data_source.dart';

/// Device-token registration.
///
/// Unlike the other repositories in this layer, the implementation **swallows**
/// failures and returns false rather than rethrowing the [AppException]. Push
/// registration is fire-and-forget background work triggered by login and by
/// app resume; surfacing an error from it would put a failure in front of a user
/// who never asked for anything. Callers retry on the next resume instead.
abstract class PushRepository {
  Future<bool> registerToken({
    required String deviceId,
    required String platform,
    required String fcmToken,
  });
}

class PushRepositoryImpl implements PushRepository {
  final PushRemoteDataSource remote;

  PushRepositoryImpl(this.remote);

  @override
  Future<bool> registerToken({
    required String deviceId,
    required String platform,
    required String fcmToken,
  }) async {
    try {
      return await remote.registerFcmToken(
        deviceId: deviceId,
        platform: platform,
        fcmToken: fcmToken,
      );
    } catch (e) {
      debugPrint('[Push] Token registration failed: $e');
      return false;
    }
  }
}
