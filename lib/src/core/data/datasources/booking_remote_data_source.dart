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

  /// Bookings list (`POST /api/Booking/paginated`). Used by the driver app,
  /// which filters the returned rows client-side by the assigned `driverId`.
  Future<PagedResponse<Booking>> paginated(PaginationParams params);

  /// A specific driver's bookings (`POST /api/Booking/driver/{driverId}/paginated`).
  /// Server-scoped to the driver — no client-side filtering needed.
  Future<PagedResponse<Booking>> driverPaginated(int driverId, PaginationParams params);

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

  /// Driver/owner approves (confirms) a booking request
  /// (`POST /api/Booking/approve`). [confirmedBy] is the acting user's id.
  Future<bool> approve({required int id, required int confirmedBy});

  /// Driver/owner rejects a booking request (`POST /api/Booking/reject`) with
  /// an optional [reason]. [confirmedBy] is the acting user's id.
  Future<bool> reject({required int id, required int confirmedBy, String? reason});

  /// Marks an in-progress booking as completed (`POST /api/Booking/{id}/complete`).
  Future<bool> complete(int id);
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
  Future<PagedResponse<Booking>> paginated(PaginationParams params) async {
    try {
      final res = await apiClient.post(ApiEndpoints.bookingPaginated, data: params.toJson());
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
  Future<PagedResponse<Booking>> driverPaginated(int driverId, PaginationParams params) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.bookingDriverPaginated(driverId),
        data: params.toJson(),
      );
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

  @override
  Future<bool> approve({required int id, required int confirmedBy}) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.bookingApprove,
        data: {'id': id, 'confirmedBy': confirmedBy},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true) return true;
      throw AppException(message: _message(body) ?? 'Could not approve booking');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<bool> reject({required int id, required int confirmedBy, String? reason}) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.bookingReject,
        data: {
          'id': id,
          'confirmedBy': confirmedBy,
          if (reason != null && reason.trim().isNotEmpty) 'rejectionReason': reason.trim(),
        },
      );
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true) return true;
      throw AppException(message: _message(body) ?? 'Could not reject booking');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<bool> complete(int id) async {
    try {
      final res = await apiClient.post(ApiEndpoints.bookingComplete(id));
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true) return true;
      throw AppException(message: _message(body) ?? 'Could not complete trip');
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
