import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter/material.dart';

class HomeNavItem {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String key;
  final String path;
  const HomeNavItem(this.inactiveIcon, this.activeIcon, this.key, this.path);
}

// Outline (`_copy`) when inactive, bold (base) when active.
const kHomeNavItems = <HomeNavItem>[
  HomeNavItem(Iconsax.home_2_copy, Iconsax.home_2, 'home', '/home'),
  HomeNavItem(Iconsax.heart_copy, Iconsax.heart, 'favorites', '/favorites'),
  HomeNavItem(Iconsax.calendar_2_copy, Iconsax.calendar_2, 'bookings', '/bookings'),
  HomeNavItem(Iconsax.user_copy, Iconsax.user, 'profile', '/profile'),
];
