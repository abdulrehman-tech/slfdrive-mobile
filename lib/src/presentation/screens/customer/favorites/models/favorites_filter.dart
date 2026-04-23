import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class FavoritesFilter {
  final String labelKey;
  final IconData icon;
  final Color color;

  const FavoritesFilter({
    required this.labelKey,
    required this.icon,
    required this.color,
  });
}

const kFavoritesFilters = <FavoritesFilter>[
  FavoritesFilter(
    labelKey: 'favorites_filter_all',
    icon: Iconsax.heart_copy,
    color: Color(0xFF3D5AFE),
  ),
  FavoritesFilter(
    labelKey: 'favorites_filter_cars',
    icon: Iconsax.car_copy,
    color: Color(0xFF7C4DFF),
  ),
  FavoritesFilter(
    labelKey: 'favorites_filter_drivers',
    icon: Iconsax.profile_2user_copy,
    color: Color(0xFF00BCD4),
  ),
];
