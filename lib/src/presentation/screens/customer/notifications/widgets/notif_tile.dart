import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../models/notif_item.dart';
import '../provider/notifications_provider.dart';

class NotifTile extends StatelessWidget {
  final NotifItem item;
  final bool isDark;
  final ColorScheme cs;

  const NotifTile({
    super.key,
    required this.item,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta(item.category);
    final provider = context.read<NotificationsProvider>();
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 2.r),
        padding: EdgeInsets.symmetric(horizontal: 20.r),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Iconsax.trash_copy, color: const Color(0xFFE53935), size: 20.r),
      ),
      onDismissed: (_) => provider.dismiss(item.id),
      child: GestureDetector(
        onTap: () => provider.toggleRead(item.id),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: item.isRead ? 0.04 : 0.08)
                    : Colors.white.withValues(alpha: item.isRead ? 0.7 : 0.9),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: item.isRead
                      ? (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05))
                      : meta.color.withValues(alpha: 0.25),
                  width: item.isRead ? 1 : 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: meta.color.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(meta.icon, color: meta.color, size: 19.r),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13.r,
                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            if (!item.isRead)
                              Container(
                                width: 7.r,
                                height: 7.r,
                                margin: EdgeInsetsDirectional.only(top: 5.r, start: 6.r),
                                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                        SizedBox(height: 3.r),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 12.r,
                            color: cs.onSurface.withValues(alpha: 0.6),
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 6.r),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 2.r),
                              decoration: BoxDecoration(
                                color: meta.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                meta.label.tr(),
                                style: TextStyle(fontSize: 9.r, color: meta.color, fontWeight: FontWeight.w700),
                              ),
                            ),
                            SizedBox(width: 8.r),
                            Text(
                              formatRelative(item.at),
                              style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.45)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
