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
  Future<Booking?> getById(int id);
  Future<OmPayInitResponse> omPayInit(int bookingId, String clientType);
  Future<bool> omPayVerify(int bookingId, String orderId);
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
  Future<Booking?> getById(int id) => remote.getById(id);

  @override
  Future<OmPayInitResponse> omPayInit(int bookingId, String clientType) =>
      remote.omPayInit(bookingId, clientType);

  @override
  Future<bool> omPayVerify(int bookingId, String orderId) =>
      remote.omPayVerify(bookingId, orderId);
}
