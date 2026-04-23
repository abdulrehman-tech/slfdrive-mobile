import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter/material.dart';

class HomeNavItem {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String key;
  final String path;
  const HomeNavItem(this.inactiveIcon, this.activeIcon, this.key, this.path);
}

const kHomeNavItems = <HomeNavItem>[
  HomeNavItem(Iconsax.home_2, Iconsax.home_2_copy, 'home', '/home'),
  HomeNavItem(Iconsax.heart, Iconsax.heart_copy, 'favorites', '/favorites'),
  HomeNavItem(Iconsax.calendar_2, Iconsax.calendar_2_copy, 'bookings', '/bookings'),
  HomeNavItem(Iconsax.user, Iconsax.user_copy, 'profile', '/profile'),
];
