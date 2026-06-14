import '../../../constants/endpoints.dart';
import '../../errors/app_exception.dart';
import '../../errors/error_handler.dart';
import '../../models/booking/booking.dart';
import '../../models/booking/booking_creation_request.dart';
import '../../models/booking/ompay.dart';
import '../../models/common/paged_response.dart';
import '../../models/common/pagination_params.dart';
import '../../network/api_client.dart';

/// Remote reads/writes for customer bookings (`/api/Booking/*`).
abstract class BookingRemoteDataSource {
  /// Creates a booking (`POST /api/Booking/create`).
  Future<BookingCreationResponse> create(BookingCreationRequest request);

  /// The signed-in customer's bookings (`POST /api/Booking/my/paginated`).
  Future<PagedResponse<Booking>> myPaginated(PaginationParams params);

  /// Single booking (`GET /api/Booking/{id}`), or null when not found.
  Future<Booking?> getById(int id);

  /// Records a non-gateway payment for a booking (`POST /api/Booking/pay`),
  /// e.g. cash. Returns true on success.
  Future<bool> pay({required int bookingId, required int paymentTypeId});

  /// Starts an OmPay checkout for a booking
  /// (`POST /api/Booking/{id}/pay/ompay/init`).
  Future<OmPayInitResponse> omPayInit(int bookingId, String clientType);

  /// Verifies an OmPay order after redirect
  /// (`GET /api/Booking/{id}/pay/ompay/verify?orderId=`). Returns true on a
  /// successful/paid result.
  Future<bool> omPayVerify(int bookingId, String orderId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient apiClient;

  BookingRemoteDataSourceImpl(this.apiClient);

  @override
  Future<BookingCreationResponse> create(BookingCreationRequest request) async {
    try {
      final res = await apiClient.post(ApiEndpoints.bookingCreate, data: request.toJson());
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return BookingCreationResponse.fromJson(body['data'] as Map<String, dynamic>);
      }
      throw AppException(message: _message(body) ?? 'Booking failed');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<PagedResponse<Booking>> myPaginated(PaginationParams params) async {
    try {
      final res = await apiClient.post(ApiEndpoints.bookingMyPaginated, data: params.toJson());
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return PagedResponse.fromJson(body['data'] as Map<String, dynamic>, Booking.fromJson);
      }
      return PagedResponse.empty<Booking>();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<Booking?> getById(int id) async {
    try {
      final res = await apiClient.get(ApiEndpoints.bookingById(id));
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return Booking.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<bool> pay({required int bookingId, required int paymentTypeId}) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.bookingPay,
        data: {'id': bookingId, 'paymentTypeId': paymentTypeId},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true) return true;
      throw AppException(message: _message(body) ?? 'Payment failed');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<OmPayInitResponse> omPayInit(int bookingId, String clientType) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.bookingOmPayInit(bookingId),
        data: {'clientType': clientType},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return OmPayInitResponse.fromJson(body['data'] as Map<String, dynamic>);
      }
      throw AppException(message: _message(body) ?? 'Payment init failed');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<bool> omPayVerify(int bookingId, String orderId) async {
    try {
      final res = await apiClient.get(
        ApiEndpoints.bookingOmPayVerify(bookingId),
        queryParameters: {'orderId': orderId},
      );
      final body = res.data as Map<String, dynamic>;
      return body['isSuccess'] == true;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  String? _message(Map<String, dynamic> body) {
    final m = body['message'];
    if (m is String && m.trim().isNotEmpty) return m;
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
    return null;
  }
}
