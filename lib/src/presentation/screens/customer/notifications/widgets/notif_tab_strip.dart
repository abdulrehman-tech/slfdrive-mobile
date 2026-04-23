import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/notifications_provider.dart';

class NotifTabStrip extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final bool compact;

  const NotifTabStrip({
    super.key,
    required this.isDark,
    required this.cs,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    return SizedBox(
      height: 44.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 16.r),
        itemCount: NotificationsProvider.tabKeys.length,
        itemBuilder: (_, i) {
          final active = provider.tab == i;
          final count = provider.countForTab(i);
          return Padding(
            padding: EdgeInsetsDirectional.only(end: 8.r),
            child: GestureDetector(
              onTap: () => provider.setTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                decoration: BoxDecoration(
                  color: active
                      ? cs.primary.withValues(alpha: isDark ? 0.2 : 0.1)
                      : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(11.r),
                  border: active ? Border.all(color: cs.primary.withValues(alpha: 0.3)) : null,
                ),
                child: Row(
                  children: [
                    Text(
                      NotificationsProvider.tabKeys[i].tr(),
                      style: TextStyle(
                        fontSize: 12.r,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(width: 6.r),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 1.r),
                      decoration: BoxDecoration(
                        color: active
                            ? cs.primary.withValues(alpha: 0.2)
                            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10.r,
                          fontWeight: FontWeight.w700,
                          color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
