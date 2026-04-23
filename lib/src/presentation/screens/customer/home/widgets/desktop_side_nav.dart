import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import 'nav_items.dart';
import 'theme_toggle_btn.dart';

class DesktopSideNav extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DesktopSideNav({
    super.key,
    required this.isDark,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 84.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111118) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 40.r),
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(color: cs.primary.withValues(alpha: 0.4), blurRadius: 12.r, offset: Offset(0, 4.r)),
              ],
            ),
            child: Icon(Iconsax.car_copy, color: Colors.white, size: 22.r),
          ),
          SizedBox(height: 36.r),
          ...List.generate(kHomeNavItems.length, (i) {
            final active = currentIndex == i;
            final item = kHomeNavItems[i];
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.r),
                decoration: BoxDecoration(
                  color: active ? cs.primary.withValues(alpha: isDark ? 0.12 : 0.07) : Colors.transparent,
                  border: active ? Border(left: BorderSide(color: cs.primary, width: 3.r)) : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      active ? item.activeIcon : item.inactiveIcon,
                      color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.45),
                      size: 22.r,
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      item.key.tr(),
                      style: TextStyle(
                        fontSize: 9.r,
                        color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.45),
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 24.r),
            child: ThemeToggleBtn(isDark: isDark, vertical: true),
          ),
        ],
      ),
    );
  }
}
