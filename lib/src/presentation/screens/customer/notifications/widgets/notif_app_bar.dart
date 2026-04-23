import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/notifications_provider.dart';
import 'unread_badge.dart';

class NotifAppBar extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const NotifAppBar({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final unread = provider.unreadCount;
    final hasItems = provider.items.isNotEmpty;

    return SliverAppBar(
      pinned: true,
      toolbarHeight: 64.r,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 12.r),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
                ),
              ),
              child: Icon(CupertinoIcons.back, color: cs.onSurface, size: 18.r),
            ),
          ),
        ),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.72),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Text(
            'notif_title'.tr(),
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          if (unread > 0) ...[
            SizedBox(width: 8.r),
            UnreadBadge(count: unread, cs: cs),
          ],
        ],
      ),
      actions: [
        GestureDetector(
          onTap: unread > 0 ? provider.markAllRead : null,
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: 8.r),
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Iconsax.tick_square_copy,
                size: 17.r,
                color: unread > 0 ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(end: 12.r),
          child: GestureDetector(
            onTap: hasItems ? provider.clearAll : null,
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Iconsax.trash_copy,
                size: 17.r,
                color: hasItems ? const Color(0xFFE53935) : cs.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
