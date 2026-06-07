import '../../models/lookup/location_option.dart';
import '../../models/lookup/offered_service.dart';
import '../../models/vehicle/vehicle_brand.dart';
import '../../models/vehicle/vehicle_model_option.dart';
import '../datasources/lookup_remote_data_source.dart';

/// Exposes shared lookup lists to the presentation layer.
abstract class LookupRepository {
  Future<List<LocationOption>> getActiveLocations();
  Future<List<VehicleBrand>> getActiveBrands();
  Future<List<VehicleModelOption>> getActiveModels();
  Future<List<VehicleModelOption>> getModelsByBrand(int brandId);
  Future<List<OfferedService>> getActiveOfferedServices();
}

class LookupRepositoryImpl implements LookupRepository {
  final LookupRemoteDataSource remote;

  LookupRepositoryImpl(this.remote);

  @override
  Future<List<LocationOption>> getActiveLocations() => remote.getActiveLocations();

  @override
  Future<List<VehicleBrand>> getActiveBrands() => remote.getActiveBrands();

  @override
  Future<List<VehicleModelOption>> getActiveModels() => remote.getActiveModels();

  @override
  Future<List<VehicleModelOption>> getModelsByBrand(int brandId) =>
      remote.getModelsByBrand(brandId);

  @override
  Future<List<OfferedService>> getActiveOfferedServices() =>
      remote.getActiveOfferedServices();
}
