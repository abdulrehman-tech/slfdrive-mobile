import '../../../constants/endpoints.dart';
import '../../errors/app_exception.dart';
import '../../errors/error_handler.dart';
import '../../models/review/review.dart';
import '../../network/api_client.dart';

/// Remote reads/writes for booking reviews (`/api/Review/*`).
abstract class ReviewRemoteDataSource {
  /// Submits a review for a booking (`POST /api/Review`).
  Future<bool> submit({required int bookingId, required int rating, String? comment});

  /// Reviews for a booking (`GET /api/Review/booking/{bookingId}`).
  Future<List<Review>> forBooking(int bookingId);

  /// Average rating for a booking (`GET /api/Review/booking/{bookingId}/average`).
  Future<double?> averageForBooking(int bookingId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSourceImpl(this.apiClient);

  @override
  Future<bool> submit({required int bookingId, required int rating, String? comment}) async {
    try {
      final res = await apiClient.post(ApiEndpoints.review, data: {
        'bookingId': bookingId,
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
        'isActive': true,
      });
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true) return true;
      throw AppException(message: (body['message'] as String?) ?? 'Review failed');
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<Review>> forBooking(int bookingId) async {
    try {
      final res = await apiClient.get(ApiEndpoints.reviewsByBooking(bookingId));
      final body = res.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map(Review.fromJson).toList();
      }
      return const [];
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<double?> averageForBooking(int bookingId) async {
    try {
      final res = await apiClient.get(ApiEndpoints.reviewAverageByBooking(bookingId));
      final body = res.data as Map<String, dynamic>;
      return (body['data'] as num?)?.toDouble();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
