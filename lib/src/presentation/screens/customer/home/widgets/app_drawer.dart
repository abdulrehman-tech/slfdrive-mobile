import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'drawer_bottom.dart';
import 'drawer_header.dart';
import 'drawer_stats.dart';

class AppDrawer extends StatelessWidget {
  final bool isDark;
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;

  const AppDrawer({
    super.key,
    required this.isDark,
    required this.currentNavIndex,
    required this.onNavTap,
  });

  static const _navItems = [
    (Iconsax.home_2_copy, Iconsax.home_2, 'home'),
    (Iconsax.heart_copy, Iconsax.heart, 'favorites'),
    (Iconsax.calendar_2_copy, Iconsax.calendar_2, 'bookings'),
    (Iconsax.car_copy, Iconsax.car, 'my_vehicles'),
    (Iconsax.user_copy, Iconsax.user, 'profile'),
  ];

  static const _navColors = [
    Color(0xFF3D5AFE),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFF7C4DFF),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surfaceBg = isDark ? const Color(0xFF0F0F18) : const Color(0xFFF7F8FC);
    final cardBg = isDark ? const Color(0xFF1A1A28) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.06);

    return Drawer(
      width: 295.r,
      backgroundColor: surfaceBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(28.r), bottomRight: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          DrawerHeaderSection(isDark: isDark),
          DrawerStats(isDark: isDark, cardBg: cardBg, borderCol: borderCol),
          SizedBox(height: 8.r),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
              itemCount: _navItems.length,
              itemBuilder: (_, i) {
                final item = _navItems[i];
                final active = currentNavIndex == i;
                final col = _navColors[i];

                return GestureDetector(
                  onTap: () => onNavTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.only(bottom: 6.r),
                    padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 13.r),
                    decoration: BoxDecoration(
                      color: active ? col.withValues(alpha: isDark ? 0.18 : 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                      border: active ? Border.all(color: col.withValues(alpha: 0.25), width: 1) : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: active
                                ? col.withValues(alpha: isDark ? 0.22 : 0.14)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            active ? item.$1 : item.$2,
                            color: active ? col : cs.onSurface.withValues(alpha: 0.45),
                            size: 19.r,
                          ),
                        ),
                        SizedBox(width: 12.r),
                        Expanded(
                          child: Text(
                            item.$3.tr(),
                            style: TextStyle(
                              fontSize: 14.r,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? col : cs.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                        if (active)
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          DrawerBottom(isDark: isDark, borderCol: borderCol),
        ],
      ),
    );
  }
}
