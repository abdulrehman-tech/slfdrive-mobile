import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/customer_remote_data_source.dart';
import '../data/datasources/driver_remote_data_source.dart';
import '../data/datasources/driver_listing_remote_data_source.dart';
import '../data/datasources/lookup_remote_data_source.dart';
import '../data/datasources/vehicle_remote_data_source.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/driver_repository.dart';
import '../data/repositories/driver_listing_repository.dart';
import '../data/repositories/lookup_repository.dart';
import '../data/repositories/vehicle_repository.dart';
import '../network/api_client.dart';
import '../../presentation/providers/auth_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // Network
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<FlutterSecureStorage>()),
  );

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<LookupRemoteDataSource>(
    () => LookupRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DriverListingRemoteDataSource>(
    () => DriverListingRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<LookupRepository>(
    () => LookupRepositoryImpl(getIt<LookupRemoteDataSource>()),
  );
  getIt.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(getIt<DriverRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(getIt<CustomerRemoteDataSource>()),
  );
  getIt.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(getIt<VehicleRemoteDataSource>()),
  );
  getIt.registerLazySingleton<DriverListingRepository>(
    () => DriverListingRepositoryImpl(getIt<DriverListingRemoteDataSource>()),
  );

  // Providers
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      getIt<AuthRepository>(),
      getIt<FlutterSecureStorage>(),
      getIt<DriverRepository>(),
      getIt<CustomerRepository>(),
    ),
  );
}
