import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum NotifCategory { booking, promotion, system }

enum NotifAge { today, yesterday, earlier }

class NotifItem {
  final String id;
  final NotifCategory category;
  final String title;
  final String subtitle;
  final DateTime at;
  bool isRead;

  NotifItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.at,
    this.isRead = false,
  });

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

String formatRelative(DateTime at) {
  final diff = DateTime.now().difference(at);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${at.day}/${at.month}/${at.year}';
}
