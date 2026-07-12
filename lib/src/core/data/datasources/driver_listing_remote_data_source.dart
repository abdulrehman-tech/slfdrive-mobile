import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/common/paged_response.dart';
import '../../models/common/pagination_params.dart';
import '../../models/driver/driver_listing_item.dart';
import '../../network/api_client.dart';

/// Remote reads for the customer-facing driver listing (`/api/Driver/*`).
abstract class DriverListingRemoteDataSource {
  /// Paginated drivers (`POST /api/Driver/paginated`).
  Future<PagedResponse<DriverListingItem>> getPaginated(PaginationParams params);

  /// Nearest drivers, paginated (`POST /api/Driver/nearest/paginated`).
  Future<PagedResponse<DriverListingItem>> getNearest({
    double? lat,
    double? lon,
    PaginationParams params = const PaginationParams(),
  });
}

class DriverListingRemoteDataSourceImpl implements DriverListingRemoteDataSource {
  final ApiClient apiClient;

  DriverListingRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PagedResponse<DriverListingItem>> getPaginated(PaginationParams params) async {
    try {
      final res = await apiClient.post(ApiEndpoints.driverPaginated, data: params.toJson());
      return _parsePaged(res.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<PagedResponse<DriverListingItem>> getNearest({
    double? lat,
    double? lon,
    PaginationParams params = const PaginationParams(),
  }) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.driverNearestPaginated,
        data: params.toJson(),
        queryParameters: {'lat': ?lat, 'lon': ?lon},
      );
      return _parsePaged(res.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  PagedResponse<DriverListingItem> _parsePaged(dynamic responseData) {
    // Defensive: a 401/empty or otherwise unexpected body must not throw a raw
    // cast error (that leaked to the UI as "Map<String, dynamic> is not a
    // subtype of …"). Anything that isn't the expected success envelope → empty.
    if (responseData is Map<String, dynamic> &&
        responseData['isSuccess'] == true &&
        responseData['data'] is Map<String, dynamic>) {
      return PagedResponse.fromJson(
        responseData['data'] as Map<String, dynamic>,
        DriverListingItem.fromJson,
      );
    }
    return PagedResponse.empty<DriverListingItem>();
  }
}
