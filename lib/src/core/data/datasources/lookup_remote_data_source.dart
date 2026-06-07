import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/lookup/location_option.dart';
import '../../models/lookup/offered_service.dart';
import '../../models/vehicle/vehicle_brand.dart';
import '../../models/vehicle/vehicle_model_option.dart';
import '../../network/api_client.dart';

/// Remote reads for shared lookup lists (locations, vehicle brands/models,
/// offered services) that populate pickers and filters across the app.
abstract class LookupRemoteDataSource {
  /// Active locations from `/api/Location/active`.
  Future<List<LocationOption>> getActiveLocations();

  /// Active vehicle brands from `/api/VehicleBrand/active`.
  Future<List<VehicleBrand>> getActiveBrands();

  /// Active vehicle models from `/api/VehicleModel/active`.
  Future<List<VehicleModelOption>> getActiveModels();

  /// Vehicle models for a brand from `/api/VehicleModel/brand/{brandId}`.
  Future<List<VehicleModelOption>> getModelsByBrand(int brandId);

  /// Active offered services from `/api/OfferedServices/active`.
  Future<List<OfferedService>> getActiveOfferedServices();
}

class LookupRemoteDataSourceImpl implements LookupRemoteDataSource {
  final ApiClient apiClient;

  LookupRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<LocationOption>> getActiveLocations() =>
      _getList(ApiEndpoints.activeLocations, LocationOption.fromJson);

  @override
  Future<List<VehicleBrand>> getActiveBrands() =>
      _getList(ApiEndpoints.activeVehicleBrands, VehicleBrand.fromJson);

  @override
  Future<List<VehicleModelOption>> getActiveModels() =>
      _getList(ApiEndpoints.activeVehicleModels, VehicleModelOption.fromJson);

  @override
  Future<List<VehicleModelOption>> getModelsByBrand(int brandId) =>
      _getList(ApiEndpoints.vehicleModelsByBrand(brandId), VehicleModelOption.fromJson);

  @override
  Future<List<OfferedService>> getActiveOfferedServices() =>
      _getList(ApiEndpoints.activeOfferedServices, OfferedService.fromJson);

  /// Shared GET → unwrap `data` list → map helper for the lookup endpoints.
  Future<List<T>> _getList<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final res = await apiClient.get(path);
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
      return <T>[];
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
