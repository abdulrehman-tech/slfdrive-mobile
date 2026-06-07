import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/common/paged_response.dart';
import '../../models/common/pagination_params.dart';
import '../../models/vehicle/vehicle.dart';
import '../../network/api_client.dart';

/// Remote reads for rental vehicle listings (`/api/Vehicle/*`).
abstract class VehicleRemoteDataSource {
  /// Paginated grid (`POST /api/Vehicle/paginated`).
  Future<PagedResponse<Vehicle>> getPaginated(PaginationParams params);

  /// Single vehicle (`GET /api/Vehicle/{id}`), or null when not found.
  Future<Vehicle?> getById(int id);

  /// Nearest vehicles, paginated (`POST /api/Vehicle/nearest/paginated`). When
  /// [lat]/[lon] are null the backend falls back to the full list.
  Future<PagedResponse<Vehicle>> getNearest({
    double? lat,
    double? lon,
    PaginationParams params = const PaginationParams(),
  });

  /// All vehicles for a brand (`GET /api/Vehicle/brand/{brandId}`).
  Future<List<Vehicle>> getByBrand(int brandId);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final ApiClient apiClient;

  VehicleRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PagedResponse<Vehicle>> getPaginated(PaginationParams params) async {
    try {
      final res = await apiClient.post(ApiEndpoints.vehiclePaginated, data: params.toJson());
      return _parsePaged(res.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Vehicle?> getById(int id) async {
    try {
      final res = await apiClient.get(ApiEndpoints.vehicleById(id));
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return Vehicle.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<PagedResponse<Vehicle>> getNearest({
    double? lat,
    double? lon,
    PaginationParams params = const PaginationParams(),
  }) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.vehicleNearestPaginated,
        data: params.toJson(),
        queryParameters: {'lat': ?lat, 'lon': ?lon},
      );
      return _parsePaged(res.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<Vehicle>> getByBrand(int brandId) async {
    try {
      final res = await apiClient.get(ApiEndpoints.vehiclesByBrand(brandId));
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map(Vehicle.fromJson).toList();
      }
      return const [];
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  PagedResponse<Vehicle> _parsePaged(dynamic responseData) {
    final body = responseData as Map<String, dynamic>;
    if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
      return PagedResponse.fromJson(body['data'] as Map<String, dynamic>, Vehicle.fromJson);
    }
    return PagedResponse.empty<Vehicle>();
  }
}
