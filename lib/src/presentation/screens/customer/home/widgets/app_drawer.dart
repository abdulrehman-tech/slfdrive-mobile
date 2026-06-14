import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'drawer_bottom.dart';
import 'drawer_header.dart';

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

  // Primary nav — aligned 1:1 with kHomeNavItems. ($1, $2) = (active bold,
  // inactive outline).
  static const _navItems = [
    (Iconsax.home_2, Iconsax.home_2_copy, 'home'),
    (Iconsax.heart, Iconsax.heart_copy, 'favorites'),
    (Iconsax.calendar_2, Iconsax.calendar_2_copy, 'bookings'),
    (Iconsax.user, Iconsax.user_copy, 'profile'),
  ];

  static const _navColors = [
    Color(0xFF3D5AFE),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF7C4DFF),
  ];

  // Secondary links (informational) — ($icon, labelKey, route).
  static const _secondaryItems = [
    (Iconsax.info_circle_copy, 'drawer_about', '/about'),
    (Iconsax.document_text_copy, 'drawer_terms', '/legal/terms'),
    (Iconsax.shield_tick_copy, 'drawer_privacy', '/legal/privacy'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surfaceBg = isDark ? const Color(0xFF0F0F18) : const Color(0xFFF7F8FC);
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
          SizedBox(height: 12.r),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
              children: [
                for (var i = 0; i < _navItems.length; i++)
                  _navTile(context, cs, i),
                SizedBox(height: 14.r),
                _sectionLabel(cs, 'drawer_more'.tr()),
                SizedBox(height: 6.r),
                for (final item in _secondaryItems)
                  _secondaryTile(context, cs, item.$1, item.$2, item.$3),
              ],
            ),
          ),
          DrawerBottom(isDark: isDark, borderCol: borderCol),
        ],
      ),
    );
  }

  Widget _navTile(BuildContext context, ColorScheme cs, int i) {
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
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
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
  }

  Widget _sectionLabel(ColorScheme cs, String label) {
    return Padding(
      padding: EdgeInsets.only(left: 14.r, bottom: 2.r),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.r,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: cs.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _secondaryTile(BuildContext context, ColorScheme cs, IconData icon, String labelKey, String route) {
    return GestureDetector(
      onTap: () {
        Scaffold.of(context).closeDrawer();
        context.push(route);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 11.r),
        child: Row(
          children: [
            Icon(icon, size: 18.r, color: cs.onSurface.withValues(alpha: 0.5)),
            SizedBox(width: 14.r),
            Expanded(
              child: Text(
                labelKey.tr(),
                style: TextStyle(
                  fontSize: 13.r,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            Icon(Iconsax.arrow_right_3_copy, size: 15.r, color: cs.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
