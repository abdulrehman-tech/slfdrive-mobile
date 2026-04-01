import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // Network
  // TODO: Register ApiClient
  // getIt.registerLazySingleton<ApiClient>(
  //   () => ApiClient(getIt<FlutterSecureStorage>())
  // );

  // Data Sources
  // TODO: Register data sources
  // getIt.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(getIt<ApiClient>())
  // );

  // Repositories
  // TODO: Register repositories
  // getIt.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>())
  // );

  // Providers
  // TODO: Register providers
  // getIt.registerLazySingleton<AuthProvider>(
  //   () => AuthProvider(
  //     getIt<AuthRepository>(),
  //     getIt<FlutterSecureStorage>(),
  //   ),
  // );
}
