/// Aggregated driver stats returned by `GET /api/Driver/{id}/stats`
/// (`SLF.Domain.DTOs.EntityStatsDto`). `id` is the driver's **user** id.
///
/// Ratings come from `mst_reviews`; booking counts and earnings from
/// `trn_booking`. [averageRating] is null when the driver has no reviews yet.
class DriverStats {
  final double? averageRating;
  final int totalReviews;
  final int totalBookings;
  final int pendingBookings;
  final int approvedBookings;
  final int completedBookings;
  final int rejectedBookings;

  /// Sum of `total_amount` over approved + completed bookings (status 6, 8).
  final double totalEarnings;

  /// Commission accrued over approved + completed bookings.
  final double totalCommission;

  /// Average booking value across all bookings.
  final double averageBookingValue;

  const DriverStats({
    this.averageRating,
    this.totalReviews = 0,
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.approvedBookings = 0,
    this.completedBookings = 0,
    this.rejectedBookings = 0,
    this.totalEarnings = 0,
    this.totalCommission = 0,
    this.averageBookingValue = 0,
  });

  factory DriverStats.fromJson(Map<String, dynamic> json) {
    double d(String k) => (json[k] as num?)?.toDouble() ?? 0;
    int i(String k) => (json[k] as num?)?.toInt() ?? 0;
    return DriverStats(
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: i('totalReviews'),
      totalBookings: i('totalBookings'),
      pendingBookings: i('pendingBookings'),
      approvedBookings: i('approvedBookings'),
      completedBookings: i('completedBookings'),
      rejectedBookings: i('rejectedBookings'),
      totalEarnings: d('totalEarnings'),
      totalCommission: d('totalCommission'),
      averageBookingValue: d('averageBookingValue'),
    );
  }
}
