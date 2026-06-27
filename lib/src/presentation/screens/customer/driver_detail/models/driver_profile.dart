import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/endpoints.dart';
import '../../../../../core/models/driver/driver_details.dart';
import 'driver_review.dart';

class DriverProfile {
  final String id;
  /// The driver's own id for `Booking/create` (`driverId`), distinct from the
  /// listing/route [id] used for navigation + favourites.
  final String bookingDriverId;
  final String name;
  final String coverUrl;
  final String avatarUrl;
  final double rating;
  final int trips;
  final int years;
  final String responseTime;
  final double hourlyRate;
  final double dailyRate;
  final double weeklyRate;
  final String phone;
  final String bio;
  final List<String> languages;
  final List<(IconData icon, String labelKey, Color color)> services;
  final List<(IconData icon, String label, Color color)> vehicles;
  final List<(String day, bool available)> availability;
  final List<int> reviewCounts;
  final List<DriverReview> reviews;

  const DriverProfile({
    required this.id,
    this.bookingDriverId = '',
    required this.name,
    required this.coverUrl,
    required this.avatarUrl,
    required this.rating,
    required this.trips,
    required this.years,
    required this.responseTime,
    required this.hourlyRate,
    required this.dailyRate,
    required this.weeklyRate,
    required this.phone,
    required this.bio,
    required this.languages,
    required this.services,
    required this.vehicles,
    required this.availability,
    required this.reviewCounts,
    required this.reviews,
  });

  int get totalReviews => reviewCounts.fold(0, (a, b) => a + b);

  /// Maps a backend `DriverDetails` record onto the screen's view model.
  ///
  /// Fields the backend doesn't yet expose for a driver (services catalogue,
  /// weekly availability, per-driver review aggregate, cover image) fall back to
  /// safe empty/placeholder values rather than the old mock content. See the
  /// `listings-rating-backend-gap` note for the missing rating aggregate.
  factory DriverProfile.fromDetails(DriverDetails d) {
    final languages = (d.languagesKnown ?? '')
        .split(RegExp(r'[,/|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final daily = d.amountPerDay ?? 0;
    final vehicles = <(IconData, String, Color)>[
      if (d.hasVehicle == true) (Iconsax.car_copy, 'Vehicle', const Color(0xFF3D5AFE)),
    ];
    return DriverProfile(
      id: d.id.toString(),
      bookingDriverId: (d.driverId ?? d.id).toString(),
      name: d.fullName ?? '',
      // Empty → the cover header falls back to a bundled asset image.
      coverUrl: '',
      avatarUrl: ApiEndpoints.resolveMediaUrl(d.photoUrl) ?? '',
      rating: 0, // no per-driver aggregate endpoint yet
      trips: 0,
      years: d.yearsOfExperience ?? 0,
      responseTime: '',
      hourlyRate: d.amountPerHour ?? 0,
      dailyRate: daily,
      weeklyRate: daily * 7,
      phone: d.phoneNumber ?? '',
      bio: '',
      languages: languages,
      services: const [],
      vehicles: vehicles,
      availability: const [],
      reviewCounts: const [0, 0, 0, 0, 0],
      reviews: const [],
    );
  }
}
