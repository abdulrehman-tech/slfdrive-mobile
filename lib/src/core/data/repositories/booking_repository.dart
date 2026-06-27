import '../../models/booking/booking.dart';
import '../../models/booking/booking_creation_request.dart';
import '../../models/booking/ompay.dart';
import '../../models/common/paged_response.dart';
import '../../models/common/pagination_params.dart';
import '../datasources/booking_remote_data_source.dart';

/// Exposes customer bookings to the presentation layer.
abstract class BookingRepository {
  Future<BookingCreationResponse> create(BookingCreationRequest request);
  Future<PagedResponse<Booking>> myPaginated(PaginationParams params);
  Future<PagedResponse<Booking>> paginated(PaginationParams params);
  Future<PagedResponse<Booking>> driverPaginated(int driverId, PaginationParams params);
  Future<Booking?> getById(int id);
  Future<bool> pay({required int bookingId, required int paymentTypeId});
  Future<OmPayInitResponse> omPayInit(int bookingId, String clientType);
  Future<bool> omPayVerify(int bookingId, String orderId);
  Future<bool> approve({required int id, required int confirmedBy});
  Future<bool> reject({required int id, required int confirmedBy, String? reason});
  Future<bool> complete(int id);
}

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remote;

  BookingRepositoryImpl(this.remote);

  @override
  Future<BookingCreationResponse> create(BookingCreationRequest request) =>
      remote.create(request);

  @override
  Future<PagedResponse<Booking>> myPaginated(PaginationParams params) =>
      remote.myPaginated(params);

  @override
  Future<PagedResponse<Booking>> paginated(PaginationParams params) =>
      remote.paginated(params);

  @override
  Future<PagedResponse<Booking>> driverPaginated(int driverId, PaginationParams params) =>
      remote.driverPaginated(driverId, params);

  @override
  Future<Booking?> getById(int id) => remote.getById(id);

  @override
  Future<bool> pay({required int bookingId, required int paymentTypeId}) =>
      remote.pay(bookingId: bookingId, paymentTypeId: paymentTypeId);

  @override
  Future<OmPayInitResponse> omPayInit(int bookingId, String clientType) =>
      remote.omPayInit(bookingId, clientType);

  @override
  Future<bool> omPayVerify(int bookingId, String orderId) =>
      remote.omPayVerify(bookingId, orderId);

  @override
  Future<bool> approve({required int id, required int confirmedBy}) =>
      remote.approve(id: id, confirmedBy: confirmedBy);

  @override
  Future<bool> reject({required int id, required int confirmedBy, String? reason}) =>
      remote.reject(id: id, confirmedBy: confirmedBy, reason: reason);

  @override
  Future<bool> complete(int id) => remote.complete(id);
}
