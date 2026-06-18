import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/common/general_lookup.dart';
import '../../models/company/all_company.dart';
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

  /// All active general types from `/api/GeneralType/active`.
  Future<List<GeneralLookup>> getActiveGeneralTypes();

  /// All active general statuses from `/api/GeneralStatus/active`.
  Future<List<GeneralLookup>> getActiveGeneralStatuses();

  /// Active corporate companies from `/api/AllCompanies/active`.
  Future<List<AllCompany>> getActiveCompanies();

  /// The owning company id (`allCompanyId`) for a branch (`/api/Branch/{id}`),
  /// or null if unavailable.
  Future<int?> getBranchCompanyId(int branchId);
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

  @override
  Future<List<GeneralLookup>> getActiveGeneralTypes() =>
      _getList(ApiEndpoints.activeGeneralTypes, GeneralLookup.fromJson);

  @override
  Future<List<GeneralLookup>> getActiveGeneralStatuses() =>
      _getList(ApiEndpoints.activeGeneralStatuses, GeneralLookup.fromJson);

  @override
  Future<int?> getBranchCompanyId(int branchId) async {
    try {
      final res = await apiClient.get(ApiEndpoints.branchById(branchId));
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is Map<String, dynamic>) return (data['allCompanyId'] as num?)?.toInt();
      return null;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<AllCompany>> getActiveCompanies() async {
    // AllCompanies/active mixes corporate companies and rental companies; the
    // booking corporate picker only wants corporate ones (companyType ==
    // "Corporate"). Rental companies are excluded here.
    final all = await _getList(ApiEndpoints.activeAllCompanies, AllCompany.fromJson);
    return all
        .where((c) => (c.companyType ?? '').toLowerCase() == 'corporate')
        .toList();
  }

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
