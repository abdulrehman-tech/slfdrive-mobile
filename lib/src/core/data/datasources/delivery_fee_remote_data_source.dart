import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/delivery/delivery_fee.dart';
import '../../network/api_client.dart';

/// Remote reads for delivery fees (`/api/DeliveryFee/*`).
abstract class DeliveryFeeRemoteDataSource {
  /// Delivery fees for a company (`GET /api/DeliveryFee/by-company/{companyId}`).
  Future<List<DeliveryFee>> byCompany(int companyId);

  /// Delivery fees for an area (`GET /api/DeliveryFee/by-area/{locationId}`).
  Future<List<DeliveryFee>> byArea(int locationId);
}

class DeliveryFeeRemoteDataSourceImpl implements DeliveryFeeRemoteDataSource {
  final ApiClient apiClient;

  DeliveryFeeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<DeliveryFee>> byCompany(int companyId) =>
      _getList(ApiEndpoints.deliveryFeeByCompany(companyId));

  @override
  Future<List<DeliveryFee>> byArea(int locationId) =>
      _getList(ApiEndpoints.deliveryFeeByArea(locationId));

  Future<List<DeliveryFee>> _getList(String path) async {
    try {
      final res = await apiClient.get(path);
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is List) {
        return (body['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(DeliveryFee.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
