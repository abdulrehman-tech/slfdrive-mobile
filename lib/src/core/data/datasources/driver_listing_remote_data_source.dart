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
    final body = responseData as Map<String, dynamic>;
    if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
      return PagedResponse.fromJson(
        body['data'] as Map<String, dynamic>,
        DriverListingItem.fromJson,
      );
    }
    return PagedResponse.empty<DriverListingItem>();
  }
}
