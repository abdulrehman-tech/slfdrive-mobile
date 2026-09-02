import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/confirm_dialog.dart';
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
      // Returns false so the Dismissible never removes the row itself: the
      // provider does, once the user confirms, and the list rebuilds without it.
      // Deleting a notification is irreversible, so it asks first.
      confirmDismiss: (_) async {
        showConfirmDialog(
          context,
          isDark: isDark,
          icon: Iconsax.trash,
          accent: const Color(0xFFE53935),
          title: 'notif_delete_confirm_title',
          message: 'notif_delete_confirm_msg',
          confirmLabelKey: 'notif_delete_confirm_yes',
          onConfirm: () => provider.dismiss(item.id),
        );
        return false;
      },
      child: GestureDetector(
        // Always the detail screen — never the item's own deep link. Items that
        // aren't actionable resolve to '/notifications', so following the link
        // here pushed this same list onto the stack again and again. The detail
        // screen offers the deep link as an explicit action instead.
        onTap: () => context.push('/notifications/${item.id}'),
        onLongPress: () => provider.toggleRead(item.id),
        child: Container(
          padding: EdgeInsets.all(14.r),
          clipBehavior: Clip.antiAlias,
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
    );
  }
}
