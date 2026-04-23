import 'package:flutter/cupertino.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SortOption {
  final String id;
  final IconData icon;
  final String label;

  const SortOption({required this.id, required this.icon, required this.label});
}

const kDriverSortOptions = <SortOption>[
  SortOption(id: 'popular', icon: Iconsax.star_1, label: 'Most Popular'),
  SortOption(id: 'price_low', icon: CupertinoIcons.arrow_down, label: 'Price: Low to High'),
  SortOption(id: 'price_high', icon: CupertinoIcons.arrow_up, label: 'Price: High to Low'),
  SortOption(id: 'rating', icon: Iconsax.like_1, label: 'Highest Rated'),
  SortOption(id: 'experience', icon: Iconsax.medal_star, label: 'Most Experienced'),
];
