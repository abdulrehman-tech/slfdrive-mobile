import '../../../../../core/models/driver/driver_listing_item.dart';

class DriverItem {
  final String id;
  final String name;
  final String? imageUrl;
  final double? rating;
  final double? pricePerDay;
  final List<String> languages;
  final int? yearsExperience;
  final bool isAvailable;
  final bool hasVehicle;

  const DriverItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.rating,
    this.pricePerDay,
    this.languages = const [],
    this.yearsExperience,
    this.isAvailable = true,
    this.hasVehicle = false,
  });

  factory DriverItem.fromDriver(DriverListingItem d, {bool ar = false}) {
    return DriverItem(
      id: d.id.toString(),
      name: d.displayName(ar: ar),
      imageUrl: d.resolvedPhotoUrl,
      rating: d.rating,
      pricePerDay: d.amountPerDay,
      languages: d.languagesKnown != null && d.languagesKnown!.isNotEmpty
          ? d.languagesKnown!.split(',').map((s) => s.trim()).toList()
          : const [],
      yearsExperience: d.yearsOfExperience,
      isAvailable: d.isActive,
      hasVehicle: d.hasVehicle,
    );
  }
}
