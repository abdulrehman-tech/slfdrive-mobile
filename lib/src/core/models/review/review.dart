/// A review row (`SLF.Domain.DTOs.ReviewResponseDto`). Reviews are
/// booking-scoped on the backend (no per-vehicle/driver aggregate yet).
class Review {
  final int id;
  final int bookingId;
  final int rating;
  final String? comment;
  final bool isActive;
  final String? createdAt;
  final String? customerName;
  final String? driverName;

  /// Ids lifted from the nested `booking` object — the only way to tie a
  /// review to a vehicle / driver (the review row itself carries names only).
  final int? vehicleId;
  final int? driverId;

  const Review({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    this.isActive = true,
    this.createdAt,
    this.customerName,
    this.driverName,
    this.vehicleId,
    this.driverId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'];
    final b = booking is Map ? booking : const {};
    return Review(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: json['createdAt'] as String?,
      customerName: json['customerName'] as String?,
      driverName: json['driverName'] as String?,
      vehicleId: (b['vehicleId'] as num?)?.toInt(),
      driverId: (b['driverId'] as num?)?.toInt(),
    );
  }
}
