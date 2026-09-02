import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../widgets/confirm_dialog.dart';
import 'models/notif_item.dart';
import 'provider/notifications_provider.dart';

/// Full view of a single notification.
///
/// Every row in the list opens this, including rows that carry a deep link —
/// the link is offered here as an explicit action instead of being followed on
/// tap. Following it directly is what caused the list to push itself onto the
/// stack over and over: non-actionable items resolve to `/notifications`, so
/// tapping one re-opened the screen you were already on.
///
/// A push tap from the OS still deep-links straight to its target; that path is
/// unchanged and doesn't come through here.
class NotificationDetailScreen extends StatefulWidget {
  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Opening it counts as reading it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationsProvider>().openAndMarkRead(widget.notificationId);
    });
  }

  /// A route worth offering a button for. Anything pointing back at the inbox
  /// is not — that's the loop this screen exists to break.
  String? _actionRoute(NotifItem item) {
    final route = item.route;
    if (route == null || route.isEmpty) return null;
    if (route == '/notifications' || route.startsWith('/notifications/')) {
      return null;
    }
    return route;
  }

  String _actionLabelKey(NotifItem item) {
    switch (item.category) {
      case NotifCategory.booking:
        return 'notif_action_view_booking';
      case NotifCategory.promotion:
      case NotifCategory.system:
        return 'notif_action_view_details';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = context.watch<NotificationsProvider>().byId(widget.notificationId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _AppBar(isDark: isDark, cs: cs, item: item),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                // Desktop/tablet: a full-width column of body text is unreadable.
                constraints: BoxConstraints(maxWidth: Breakpoints.tablet.toDouble()),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 28.r),
                  child: item == null
                      ? _Missing(cs: cs)
                      : _Body(item: item, cs: cs, isDark: isDark),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: item == null ? null : _Actions(
        item: item,
        cs: cs,
        isDark: isDark,
        actionRoute: _actionRoute(item),
        actionLabelKey: _actionLabelKey(item),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final NotifItem? item;

  const _AppBar({required this.isDark, required this.cs, required this.item});

  @override
  Widget build(BuildContext context) {
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
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.07),
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
              color: isDark
                  ? Colors.black.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.72),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.07),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'notif_detail_title'.tr(),
        style: TextStyle(
          fontSize: 18.r,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final NotifItem item;
  final ColorScheme cs;
  final bool isDark;

  const _Body({required this.item, required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final meta = categoryMeta(item.category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46.r,
              height: 46.r,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(meta.icon, color: meta.color, size: 22.r),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                    decoration: BoxDecoration(
                      color: meta.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      meta.label.tr(),
                      style: TextStyle(
                        fontSize: 10.r,
                        color: meta.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.r),
                  Text(
                    formatRelative(item.at),
                    style: TextStyle(
                      fontSize: 11.r,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.r),
        if (item.title.isNotEmpty)
          Text(
            item.title,
            style: TextStyle(
              fontSize: 20.r,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: cs.onSurface,
            ),
          ),
        if (item.subtitle.isNotEmpty) ...[
          SizedBox(height: 12.r),
          SelectableText(
            item.subtitle,
            style: TextStyle(
              fontSize: 14.r,
              height: 1.55,
              color: cs.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }
}

class _Missing extends StatelessWidget {
  final ColorScheme cs;

  const _Missing({required this.cs});

  @override
  Widget build(BuildContext context) {
    // Reachable when the inbox was cleared, or when the item aged past the
    // hundred-item cap, while this screen was on the stack.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.r),
      child: Column(
        children: [
          Icon(
            Iconsax.notification_copy,
            size: 44.r,
            color: cs.onSurface.withValues(alpha: 0.25),
          ),
          SizedBox(height: 14.r),
          Text(
            'notif_detail_missing'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.r,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final NotifItem item;
  final ColorScheme cs;
  final bool isDark;
  final String? actionRoute;
  final String actionLabelKey;

  const _Actions({
    required this.item,
    required this.cs,
    required this.isDark,
    required this.actionRoute,
    required this.actionLabelKey,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(20.r, 0, 20.r, 12.r),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => showConfirmDialog(
                context,
                isDark: isDark,
                icon: Iconsax.trash,
                accent: const Color(0xFFE53935),
                title: 'notif_delete_confirm_title',
                message: 'notif_delete_confirm_msg',
                confirmLabelKey: 'notif_delete_confirm_yes',
                onConfirm: () {
                  context.read<NotificationsProvider>().dismiss(item.id);
                  Navigator.of(context).pop();
                },
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.r),
                backgroundColor: const Color(0xFFE53935).withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'delete'.tr(),
                style: TextStyle(
                  fontSize: 14.r,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE53935),
                ),
              ),
            ),
          ),
          if (actionRoute != null) ...[
            SizedBox(width: 12.r),
            Expanded(
              flex: 2,
              child: TextButton(
                onPressed: () => context.push(actionRoute!),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  actionLabelKey.tr(),
                  style: TextStyle(
                    fontSize: 14.r,
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
