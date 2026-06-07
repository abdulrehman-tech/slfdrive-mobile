import '../../../../../core/models/driver/driver_listing_item.dart';

/// Home-screen nearby driver view model. Carries the extra display fields
/// that [DriverCard] renders (trips count, speciality label) alongside the
/// common fields shared with the driver-listing screen.
///
/// [rating] is nullable — the backend currently returns null per-driver.
/// [DriverCard] renders a "New" placeholder when null (same rule as cars).
class DriverItem {
  final String id;
  final String name;
  final String avatarUrl;

  /// Aggregate driver rating. Null when the backend has no rating yet.
  final double? rating;

  /// Total completed trips. Mapped from [DriverListingItem.yearsOfExperience]
  /// as a best-effort proxy since the backend does not expose a trip count in
  /// the listing response.
  final int trips;

  /// Short role label shown in the card badge (e.g. "Chauffeur").
  /// Derived from [DriverListingItem.languagesKnown] or a generic fallback.
  final String speciality;

  const DriverItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.rating,
    this.trips = 0,
    this.speciality = '',
  });

  /// Maps a backend [DriverListingItem] to a home DriverItem.
  factory DriverItem.fromDriver(DriverListingItem d, {bool ar = false}) {
    return DriverItem(
      id: d.id.toString(),
      name: d.displayName(ar: ar),
      avatarUrl: d.resolvedPhotoUrl ?? '',
      rating: d.rating,
      // Backend listing has no trip-count field; use years of experience as a
      // proxy so the card shows a non-zero number for experienced drivers.
      trips: d.yearsOfExperience ?? 0,
      // Use the first listed language as the badge, or fall back to a generic
      // "Driver" label — both are user-visible only and not critical.
      speciality: _resolveSpeciality(d),
    );
  }

  static String _resolveSpeciality(DriverListingItem d) {
    if (d.languagesKnown != null && d.languagesKnown!.isNotEmpty) {
      return d.languagesKnown!.split(',').first.trim();
    }
    return 'Driver';
  }
}
