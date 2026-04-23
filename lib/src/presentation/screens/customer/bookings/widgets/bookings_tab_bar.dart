import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/bookings_provider.dart';

class BookingsTabBar extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final bool compact;

  const BookingsTabBar({
    super.key,
    required this.isDark,
    required this.cs,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingsProvider>();
    return Padding(
      padding: compact ? EdgeInsets.zero : EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 8.r),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: BookingsProvider.tabKeys.asMap().entries.map((e) {
            final i = e.key;
            final active = provider.tabIndex == i;
            final col = BookingsProvider.tabColors[i];
            final count = provider.countForTab(i);

            return Padding(
              padding: EdgeInsetsDirectional.only(end: 10.r),
              child: GestureDetector(
                onTap: () => provider.setTab(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                  decoration: BoxDecoration(
                    color: active
                        ? col.withValues(alpha: isDark ? 0.2 : 0.12)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(14.r),
                    border: active
                        ? Border.all(color: col.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        BookingsProvider.tabIcons[i],
                        size: 15.r,
                        color: active ? col : cs.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: 6.r),
                      Text(
                        e.value.tr(),
                        style: TextStyle(
                          fontSize: 12.r,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? col : cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (count > 0) ...[
                        SizedBox(width: 6.r),
                        Container(
                          width: 18.r,
                          height: 18.r,
                          decoration: BoxDecoration(
                            color: active
                                ? col.withValues(alpha: 0.2)
                                : cs.onSurface.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 9.r,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? col
                                    : cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
