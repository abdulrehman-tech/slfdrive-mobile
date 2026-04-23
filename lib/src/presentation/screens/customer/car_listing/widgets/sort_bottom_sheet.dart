import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Modal sheet offering sort-by options for the car listing.
class SortBottomSheet extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final String current;
  final ValueChanged<String> onSelect;

  const SortBottomSheet({
    super.key,
    required this.isDark,
    required this.cs,
    required this.current,
    required this.onSelect,
  });

  static final List<(String, IconData, String)> _options = [
    ('popular', Iconsax.star_1, 'Most Popular'),
    ('price_low', CupertinoIcons.arrow_down, 'Price: Low to High'),
    ('price_high', CupertinoIcons.arrow_up, 'Price: High to Low'),
    ('rating', Iconsax.like_1, 'Highest Rated'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 20.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.r),
                Text(
                  'car_listing_sort'.tr(),
                  style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                SizedBox(height: 16.r),
                ..._options.map((o) => _buildOption(o)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption((String, IconData, String) o) {
    final active = current == o.$1;
    return Padding(
      padding: EdgeInsets.only(bottom: 6.r),
      child: GestureDetector(
        onTap: () => onSelect(o.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 13.r),
          decoration: BoxDecoration(
            color: active ? cs.primary.withValues(alpha: isDark ? 0.15 : 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
            border: active
                ? Border.all(color: cs.primary.withValues(alpha: 0.3))
                : Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                  ),
          ),
          child: Row(
            children: [
              Icon(o.$2, size: 18.r, color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.5)),
              SizedBox(width: 12.r),
              Expanded(
                child: Text(
                  o.$3,
                  style: TextStyle(
                    fontSize: 13.r,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? cs.primary : cs.onSurface,
                  ),
                ),
              ),
              if (active)
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  child: Icon(Icons.check_rounded, size: 13.r, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
