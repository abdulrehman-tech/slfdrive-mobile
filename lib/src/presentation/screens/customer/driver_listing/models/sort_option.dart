import 'package:flutter/cupertino.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SortOption {
  final String id;
  final IconData icon;
  final String label;

  const SortOption({required this.id, required this.icon, required this.label});
}

// `label` holds a translation KEY — render with `.tr()`.
const kDriverSortOptions = <SortOption>[
  SortOption(id: 'popular', icon: Iconsax.star_1, label: 'sort_popular'),
  SortOption(id: 'price_low', icon: CupertinoIcons.arrow_down, label: 'sort_price_low'),
  SortOption(id: 'price_high', icon: CupertinoIcons.arrow_up, label: 'sort_price_high'),
  SortOption(id: 'experience', icon: Iconsax.medal_star, label: 'sort_experience'),
];
