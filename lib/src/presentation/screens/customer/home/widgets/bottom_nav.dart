import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'nav_items.dart';

class HomeBottomNav extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.isDark,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 64.r,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(32.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.10),
                blurRadius: 28.r,
                spreadRadius: -2,
                offset: Offset(0, 8.r),
              ),
            ],
          ),
          child: Row(
            children: List.generate(kHomeNavItems.length, (i) {
              final active = currentIndex == i;
              final item = kHomeNavItems[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 5.r),
                        decoration: BoxDecoration(
                          color: active ? cs.primary.withValues(alpha: isDark ? 0.25 : 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          active ? item.activeIcon : item.inactiveIcon,
                          color: active ? cs.primary : cs.onSurface.withValues(alpha: isDark ? 0.35 : 0.4),
                          size: 22.r,
                        ),
                      ),
                      SizedBox(height: 2.r),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 10.r,
                          color: active ? cs.primary : cs.onSurface.withValues(alpha: isDark ? 0.35 : 0.4),
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                        ),
                        child: Text(item.key.tr()),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
