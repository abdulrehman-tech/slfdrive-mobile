import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/lookup/location_option.dart';
import '../../network/api_client.dart';

/// Remote reads for shared lookup lists (locations, and later cities, brands,
/// etc.) that populate pickers across the app.
abstract class LookupRemoteDataSource {
  /// Active locations from `/api/Location/active`.
  Future<List<LocationOption>> getActiveLocations();
}

class LookupRemoteDataSourceImpl implements LookupRemoteDataSource {
  final ApiClient apiClient;

  LookupRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<LocationOption>> getActiveLocations() async {
    try {
      final res = await apiClient.get(ApiEndpoints.activeLocations);
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(LocationOption.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
