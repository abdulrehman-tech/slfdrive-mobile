import '../../models/review/review.dart';
import '../datasources/review_remote_data_source.dart';

/// Exposes booking reviews to the presentation layer.
abstract class ReviewRepository {
  Future<bool> submit({required int bookingId, required int rating, String? comment});
  Future<List<Review>> forBooking(int bookingId);
  Future<double?> averageForBooking(int bookingId);
}

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remote;

  ReviewRepositoryImpl(this.remote);

  @override
  Future<bool> submit({required int bookingId, required int rating, String? comment}) =>
      remote.submit(bookingId: bookingId, rating: rating, comment: comment);

  @override
  Future<List<Review>> forBooking(int bookingId) => remote.forBooking(bookingId);

  @override
  Future<double?> averageForBooking(int bookingId) => remote.averageForBooking(bookingId);
}
