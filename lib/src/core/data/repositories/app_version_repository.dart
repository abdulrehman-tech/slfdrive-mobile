import '../../models/app/app_version_info.dart';
import '../datasources/app_version_remote_data_source.dart';

/// Exposes the published app version to the splash force-update gate.
abstract class AppVersionRepository {
  Future<AppVersionInfo?> check(String appName);
}

class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionRemoteDataSource remote;

  AppVersionRepositoryImpl(this.remote);

  @override
  Future<AppVersionInfo?> check(String appName) => remote.check(appName);
}
