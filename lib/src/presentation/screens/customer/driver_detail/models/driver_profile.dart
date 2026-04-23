import 'package:flutter/material.dart';

import 'driver_review.dart';

class DriverProfile {
  final String id;
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
}
