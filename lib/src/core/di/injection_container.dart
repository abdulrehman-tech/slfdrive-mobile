import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/booking_remote_data_source.dart';
import '../data/datasources/corporate_membership_remote_data_source.dart';
import '../data/datasources/customer_remote_data_source.dart';
import '../data/datasources/delivery_fee_remote_data_source.dart';
import '../data/datasources/driver_remote_data_source.dart';
import '../data/datasources/driver_listing_remote_data_source.dart';
import '../data/datasources/lookup_remote_data_source.dart';
import '../data/datasources/review_remote_data_source.dart';
import '../data/datasources/vehicle_remote_data_source.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/booking_repository.dart';
import '../data/repositories/corporate_membership_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/delivery_fee_repository.dart';
import '../data/repositories/driver_repository.dart';
import '../data/repositories/driver_listing_repository.dart';
import '../data/repositories/lookup_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/vehicle_repository.dart';
import '../network/api_client.dart';
import '../services/booking_lookups.dart';
import '../services/customer_avatars.dart';
import '../services/driver_session.dart';
import '../services/place_namer.dart';
import '../services/session_manager.dart';
import '../../presentation/providers/auth_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // Global session-expiry signal (fired by the auth interceptor when a token
  // can't be refreshed). Registered before ApiClient, which wires it into the
  // interceptor.
  getIt.registerLazySingleton<SessionManager>(() => SessionManager());

  // Network
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<FlutterSecureStorage>(), getIt<SessionManager>()),
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
  getIt.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CorporateMembershipRemoteDataSource>(
    () => CorporateMembershipRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DeliveryFeeRemoteDataSource>(
    () => DeliveryFeeRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(getIt<ApiClient>()),
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
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(getIt<BookingRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CorporateMembershipRepository>(
    () => CorporateMembershipRepositoryImpl(
      getIt<CorporateMembershipRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<DeliveryFeeRepository>(
    () => DeliveryFeeRepositoryImpl(getIt<DeliveryFeeRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(getIt<ReviewRemoteDataSource>()),
  );

  // Services
  getIt.registerLazySingleton<BookingLookups>(
    () => BookingLookups(getIt<LookupRepository>()),
  );
  getIt.registerLazySingleton<DriverSession>(
    () => DriverSession(getIt<DriverRepository>(), getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<PlaceNamer>(
    () => PlaceNamer(getIt<LookupRepository>()),
  );
  getIt.registerLazySingleton<CustomerAvatars>(
    () => CustomerAvatars(getIt<CustomerRepository>()),
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
