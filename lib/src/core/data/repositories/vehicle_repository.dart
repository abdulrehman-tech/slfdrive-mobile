import '../../models/common/paged_response.dart';
import '../../models/common/pagination_params.dart';
import '../../models/vehicle/vehicle.dart';
import '../datasources/vehicle_remote_data_source.dart';

/// Exposes vehicle listings to the presentation layer.
abstract class VehicleRepository {
  Future<PagedResponse<Vehicle>> getPaginated(PaginationParams params);
  Future<Vehicle?> getById(int id);
  Future<PagedResponse<Vehicle>> getNearest({
    double? lat,
    double? lon,
    PaginationParams params,
  });
  Future<List<Vehicle>> getByBrand(int brandId);
}

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remote;

  VehicleRepositoryImpl(this.remote);

  @override
  Future<PagedResponse<Vehicle>> getPaginated(PaginationParams params) =>
      remote.getPaginated(params);

  @override
  Future<Vehicle?> getById(int id) => remote.getById(id);

  @override
  Future<PagedResponse<Vehicle>> getNearest({
    double? lat,
    double? lon,
    PaginationParams params = const PaginationParams(),
  }) =>
      remote.getNearest(lat: lat, lon: lon, params: params);

  @override
  Future<List<Vehicle>> getByBrand(int brandId) => remote.getByBrand(brandId);
}
