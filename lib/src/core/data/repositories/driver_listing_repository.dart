import '../../models/common/paged_response.dart';
import '../../models/common/pagination_params.dart';
import '../../models/driver/driver_listing_item.dart';
import '../datasources/driver_listing_remote_data_source.dart';

/// Exposes the customer-facing driver listing to the presentation layer.
abstract class DriverListingRepository {
  Future<PagedResponse<DriverListingItem>> getPaginated(PaginationParams params);
  Future<PagedResponse<DriverListingItem>> getNearest({
    double? lat,
    double? lon,
    PaginationParams params,
  });
}

class DriverListingRepositoryImpl implements DriverListingRepository {
  final DriverListingRemoteDataSource remote;

  DriverListingRepositoryImpl(this.remote);

  @override
  Future<PagedResponse<DriverListingItem>> getPaginated(PaginationParams params) =>
      remote.getPaginated(params);

  @override
  Future<PagedResponse<DriverListingItem>> getNearest({
    double? lat,
    double? lon,
    PaginationParams params = const PaginationParams(),
  }) =>
      remote.getNearest(lat: lat, lon: lon, params: params);
}
