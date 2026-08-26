/// Aggregated per-entity stats (`SLF.Domain.DTOs.EntityStatsDto`) as returned
/// by `GET /api/Vehicle/{id}/stats`. Ratings come from `mst_reviews`; booking
/// counts from `trn_booking`. [averageRating] is null with no reviews yet.
/// (The driver side keeps its own identical `DriverStats`.)
class EntityStats {
  final double? averageRating;
  final int totalReviews;
  final int totalBookings;
  final int completedBookings;

  const EntityStats({
    this.averageRating,
    this.totalReviews = 0,
    this.totalBookings = 0,
    this.completedBookings = 0,
  });

  factory EntityStats.fromJson(Map<String, dynamic> json) {
    int i(String k) => (json[k] as num?)?.toInt() ?? 0;
    return EntityStats(
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: i('totalReviews'),
      totalBookings: i('totalBookings'),
      completedBookings: i('completedBookings'),
    );
  }
}
