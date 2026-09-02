import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/notification/push_payload.dart';

enum NotifCategory { booking, promotion, system }

enum NotifAge { today, yesterday, earlier }

class NotifItem {
  final String id;
  final NotifCategory category;
  final String title;
  final String subtitle;
  final DateTime at;
  bool isRead;

  /// In-app route this item opens when tapped, already resolved against the
  /// signed-in role. Null when the push isn't actionable (promotions, system
  /// messages, or a payload this build doesn't understand).
  final String? route;

  /// Raw push `data`, kept so a future build can route on keys this one ignores
  /// without losing them from already-stored items.
  final Map<String, String> data;

  NotifItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.at,
    this.isRead = false,
    this.route,
    this.data = const {},
  });

  /// Builds an inbox row from a received push. [route] comes from the caller
  /// because resolving it needs the role, which lives in the presentation layer.
  factory NotifItem.fromPush(PushPayload p, {String? route}) => NotifItem(
        id: p.id,
        category: categoryFromKey(p.category),
        title: p.title ?? '',
        subtitle: p.body ?? '',
        at: p.sentAt,
        route: route,
        data: p.data,
      );

  factory NotifItem.fromJson(Map<String, dynamic> json) => NotifItem(
        id: '${json['id']}',
        category: categoryFromKey(json['category'] as String?),
        title: (json['title'] as String?) ?? '',
        subtitle: (json['subtitle'] as String?) ?? '',
        at: DateTime.tryParse('${json['at']}')?.toLocal() ?? DateTime.now(),
        isRead: json['isRead'] == true,
        route: json['route'] as String?,
        data: {
          for (final e in (json['data'] as Map? ?? const {}).entries)
            '${e.key}': '${e.value}',
        },
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'title': title,
        'subtitle': subtitle,
        'at': at.toIso8601String(),
        'isRead': isRead,
        'route': route,
        'data': data,
      };

  /// Tolerant decode — an unrecognised category (a newer server type reaching an
  /// older build) lands in `system` rather than throwing away the notification.
  static NotifCategory categoryFromKey(String? key) {
    switch (key) {
      case 'booking':
        return NotifCategory.booking;
      case 'promotion':
        return NotifCategory.promotion;
      default:
        return NotifCategory.system;
    }
  }

  NotifAge get age {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(at.year, at.month, at.day);
    final diff = today.difference(d).inDays;
    if (diff <= 0) return NotifAge.today;
    if (diff == 1) return NotifAge.yesterday;
    return NotifAge.earlier;
  }
}

class CategoryMeta {
  final IconData icon;
  final Color color;
  final String label;
  const CategoryMeta(this.icon, this.color, this.label);
}

CategoryMeta categoryMeta(NotifCategory c) {
  switch (c) {
    case NotifCategory.booking:
      return const CategoryMeta(Iconsax.calendar_tick_copy, Color(0xFF3D5AFE), 'notif_cat_booking');
    case NotifCategory.promotion:
      return const CategoryMeta(Iconsax.discount_shape_copy, Color(0xFFFF6D00), 'notif_cat_promotion');
    case NotifCategory.system:
      return const CategoryMeta(Iconsax.security_safe_copy, Color(0xFF7C4DFF), 'notif_cat_system');
  }
}

String ageLabelKey(NotifAge age) {
  switch (age) {
    case NotifAge.today:
      return 'notif_group_today';
    case NotifAge.yesterday:
      return 'notif_group_yesterday';
    case NotifAge.earlier:
      return 'notif_group_earlier';
  }
}

/// Relative timestamp for a notification row. Localised — the list is no longer
/// always empty, so these strings are user-visible in every locale.
String formatRelative(DateTime at) {
  final diff = DateTime.now().difference(at);
  if (diff.inMinutes < 1) return 'notif_time_now'.tr();
  if (diff.inMinutes < 60) {
    return 'notif_time_minutes'.tr(namedArgs: {'n': '${diff.inMinutes}'});
  }
  if (diff.inHours < 24) {
    return 'notif_time_hours'.tr(namedArgs: {'n': '${diff.inHours}'});
  }
  if (diff.inDays < 7) {
    return 'notif_time_days'.tr(namedArgs: {'n': '${diff.inDays}'});
  }
  return DateFormat.yMd(Intl.getCurrentLocale()).format(at);
}
