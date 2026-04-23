import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/notifications_provider.dart';
import 'notif_action_button.dart';
import 'unread_badge.dart';

class NotifDesktopHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const NotifDesktopHeader({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final unread = provider.unreadCount;
    final hasItems = provider.items.isNotEmpty;

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(CupertinoIcons.back, size: 18.r, color: cs.onSurface),
          ),
        ),
        SizedBox(width: 14.r),
        Text(
          'notif_title'.tr(),
          style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        if (unread > 0) ...[
          SizedBox(width: 10.r),
          UnreadBadge(count: unread, cs: cs),
        ],
        const Spacer(),
        NotifActionButton(
          icon: Iconsax.tick_square_copy,
          label: 'notif_mark_all_read'.tr(),
          isDark: isDark,
          cs: cs,
          enabled: unread > 0,
          onTap: provider.markAllRead,
        ),
        SizedBox(width: 8.r),
        NotifActionButton(
          icon: Iconsax.trash_copy,
          label: 'notif_clear_all'.tr(),
          isDark: isDark,
          cs: cs,
          enabled: hasItems,
          onTap: provider.clearAll,
          danger: true,
        ),
      ],
    );
  }
}
