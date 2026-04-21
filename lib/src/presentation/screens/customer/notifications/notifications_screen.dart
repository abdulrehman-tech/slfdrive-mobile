import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';

// ============================================================
// MODEL + MOCK DATA
// ============================================================

enum NotifCategory { booking, promotion, system }

enum _Age { today, yesterday, earlier }

class _NotifItem {
  final String id;
  final NotifCategory category;
  final String title;
  final String subtitle;
  final DateTime at;
  bool isRead;

  _NotifItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.at,
    this.isRead = false,
  });

  _Age get age {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(at.year, at.month, at.day);
    final diff = today.difference(d).inDays;
    if (diff <= 0) return _Age.today;
    if (diff == 1) return _Age.yesterday;
    return _Age.earlier;
  }
}

List<_NotifItem> _seedNotifs() {
  final now = DateTime.now();
  return [
    _NotifItem(
      id: 'n1',
      category: NotifCategory.booking,
      title: 'Booking confirmed',
      subtitle: 'Your Mercedes AMG GT for Jan 15 has been confirmed.',
      at: now.subtract(const Duration(minutes: 20)),
    ),
    _NotifItem(
      id: 'n2',
      category: NotifCategory.promotion,
      title: 'Weekend flash sale • 20% off',
      subtitle: 'Tap to view exclusive weekend deals on premium cars.',
      at: now.subtract(const Duration(hours: 3)),
    ),
    _NotifItem(
      id: 'n3',
      category: NotifCategory.system,
      title: 'New app version available',
      subtitle: 'Update to unlock faster search and improved maps.',
      at: now.subtract(const Duration(hours: 7)),
      isRead: true,
    ),
    _NotifItem(
      id: 'n4',
      category: NotifCategory.booking,
      title: 'Driver on the way',
      subtitle: 'Ahmed will arrive at Muscat Airport in ~12 minutes.',
      at: now.subtract(const Duration(days: 1, hours: 2)),
    ),
    _NotifItem(
      id: 'n5',
      category: NotifCategory.promotion,
      title: 'Your referral earned 5 OMR',
      subtitle: 'Omar just completed his first trip with your code.',
      at: now.subtract(const Duration(days: 1, hours: 6)),
      isRead: true,
    ),
    _NotifItem(
      id: 'n6',
      category: NotifCategory.system,
      title: 'Security alert',
      subtitle: 'Sign-in from new device detected in Muscat.',
      at: now.subtract(const Duration(days: 3)),
      isRead: true,
    ),
    _NotifItem(
      id: 'n7',
      category: NotifCategory.booking,
      title: 'Rate your last trip',
      subtitle: 'How was your experience with Yusuf? Leave a review.',
      at: now.subtract(const Duration(days: 5)),
      isRead: true,
    ),
  ];
}

// ============================================================
// NOTIFICATIONS SCREEN
// ============================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_NotifItem> _items;
  int _tab = 0; // 0=All, 1=Bookings, 2=Promotions, 3=System

  static const _categoryMap = [null, NotifCategory.booking, NotifCategory.promotion, NotifCategory.system];
  static const _tabKeys = ['notif_tab_all', 'notif_tab_bookings', 'notif_tab_promos', 'notif_tab_system'];

  @override
  void initState() {
    super.initState();
    _items = _seedNotifs();
  }

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  List<_NotifItem> get _filtered {
    final cat = _categoryMap[_tab];
    if (cat == null) return _items;
    return _items.where((n) => n.category == cat).toList();
  }

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _items) {
        n.isRead = true;
      }
    });
  }

  void _clearAll() {
    setState(() => _items.clear());
  }

  void _dismiss(String id) {
    setState(() => _items.removeWhere((n) => n.id == id));
  }

  void _toggleRead(String id) {
    setState(() {
      final i = _items.indexWhere((n) => n.id == id);
      if (i != -1) _items[i].isRead = !_items[i].isRead;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  // ==========================================================================
  // MOBILE
  // ==========================================================================

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(isDark, cs),
        SliverToBoxAdapter(child: _buildTabs(isDark, cs)),
        ..._buildGroupedSlivers(isDark, cs),
        SliverToBoxAdapter(child: SizedBox(height: 40.r)),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP
  // ==========================================================================

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 900.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  if (_unreadCount > 0) ...[
                    SizedBox(width: 10.r),
                    _UnreadBadge(count: _unreadCount, cs: cs),
                  ],
                  const Spacer(),
                  _buildActionButton(
                    icon: Iconsax.tick_square_copy,
                    label: 'notif_mark_all_read'.tr(),
                    isDark: isDark,
                    cs: cs,
                    enabled: _unreadCount > 0,
                    onTap: _markAllRead,
                  ),
                  SizedBox(width: 8.r),
                  _buildActionButton(
                    icon: Iconsax.trash_copy,
                    label: 'notif_clear_all'.tr(),
                    isDark: isDark,
                    cs: cs,
                    enabled: _items.isNotEmpty,
                    onTap: _clearAll,
                    danger: true,
                  ),
                ],
              ),
              SizedBox(height: 16.r),
              _buildTabs(isDark, cs, compact: true),
              SizedBox(height: 8.r),
              _filtered.isEmpty
                  ? SizedBox(height: 420.r, child: _buildEmpty(isDark, cs))
                  : Column(children: _buildGroupedSections(isDark, cs)),
              SizedBox(height: 32.r),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // APP BAR (mobile)
  // ==========================================================================

  Widget _buildAppBar(bool isDark, ColorScheme cs) {
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
          if (_unreadCount > 0) ...[
            SizedBox(width: 8.r),
            _UnreadBadge(count: _unreadCount, cs: cs),
          ],
        ],
      ),
      actions: [
        GestureDetector(
          onTap: _unreadCount > 0 ? _markAllRead : null,
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
                color: _unreadCount > 0 ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(end: 12.r),
          child: GestureDetector(
            onTap: _items.isEmpty ? null : _clearAll,
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
                color: _items.isEmpty ? cs.onSurface.withValues(alpha: 0.3) : const Color(0xFFE53935),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TABS
  // ==========================================================================

  Widget _buildTabs(bool isDark, ColorScheme cs, {bool compact = false}) {
    return SizedBox(
      height: 44.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 16.r),
        itemCount: _tabKeys.length,
        itemBuilder: (_, i) {
          final active = _tab == i;
          final count = i == 0
              ? _items.length
              : _items.where((n) => n.category == _categoryMap[i]).length;
          return Padding(
            padding: EdgeInsetsDirectional.only(end: 8.r),
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
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
                      _tabKeys[i].tr(),
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

  // ==========================================================================
  // GROUPED LIST
  // ==========================================================================

  List<Widget> _buildGroupedSlivers(bool isDark, ColorScheme cs) {
    final list = _filtered;
    if (list.isEmpty) {
      return [
        SliverFillRemaining(hasScrollBody: false, child: _buildEmpty(isDark, cs)),
      ];
    }

    final groups = <_Age, List<_NotifItem>>{};
    for (final n in list) {
      groups.putIfAbsent(n.age, () => []).add(n);
    }

    final slivers = <Widget>[];
    for (final age in _Age.values) {
      final entries = groups[age];
      if (entries == null || entries.isEmpty) continue;
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.r, 18.r, 16.r, 8.r),
            child: Text(
              _ageLabel(age).tr(),
              style: TextStyle(
                fontSize: 13.r,
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.55),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.r),
          sliver: SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(bottom: 10.r),
              child: _buildTile(entries[i], isDark, cs),
            ),
          ),
        ),
      );
    }
    return slivers;
  }

  List<Widget> _buildGroupedSections(bool isDark, ColorScheme cs) {
    final list = _filtered;
    final groups = <_Age, List<_NotifItem>>{};
    for (final n in list) {
      groups.putIfAbsent(n.age, () => []).add(n);
    }
    final widgets = <Widget>[];
    for (final age in _Age.values) {
      final entries = groups[age];
      if (entries == null || entries.isEmpty) continue;
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(4.r, 18.r, 0, 8.r),
          child: Text(
            _ageLabel(age).tr(),
            style: TextStyle(
              fontSize: 13.r,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
      );
      widgets.addAll(entries.map((e) => Padding(padding: EdgeInsets.only(bottom: 10.r), child: _buildTile(e, isDark, cs))));
    }
    return widgets;
  }

  String _ageLabel(_Age age) {
    switch (age) {
      case _Age.today:
        return 'notif_group_today';
      case _Age.yesterday:
        return 'notif_group_yesterday';
      case _Age.earlier:
        return 'notif_group_earlier';
    }
  }

  // ==========================================================================
  // TILE
  // ==========================================================================

  Widget _buildTile(_NotifItem n, bool isDark, ColorScheme cs) {
    final meta = _categoryMeta(n.category);
    return Dismissible(
      key: ValueKey(n.id),
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
      onDismissed: (_) => _dismiss(n.id),
      child: GestureDetector(
        onTap: () => _toggleRead(n.id),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: n.isRead ? 0.04 : 0.08)
                    : Colors.white.withValues(alpha: n.isRead ? 0.7 : 0.9),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: n.isRead
                      ? (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05))
                      : meta.color.withValues(alpha: 0.25),
                  width: n.isRead ? 1 : 1.2,
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
                                n.title,
                                style: TextStyle(
                                  fontSize: 13.r,
                                  fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            if (!n.isRead)
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
                          n.subtitle,
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
                              _formatRelative(n.at),
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

  // ==========================================================================
  // ACTION BUTTON (desktop top-right)
  // ==========================================================================

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required ColorScheme cs,
    required VoidCallback onTap,
    bool enabled = true,
    bool danger = false,
  }) {
    final color = danger ? const Color(0xFFE53935) : cs.primary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 9.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15.r, color: color),
              SizedBox(width: 6.r),
              Text(label, style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // EMPTY
  // ==========================================================================

  Widget _buildEmpty(bool isDark, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82.r,
            height: 82.r,
            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary.withValues(alpha: 0.08)),
            child: Icon(Iconsax.notification_copy, size: 38.r, color: cs.primary.withValues(alpha: 0.5)),
          ),
          SizedBox(height: 14.r),
          Text(
            'notif_empty_title'.tr(),
            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          SizedBox(height: 4.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.r),
            child: Text(
              'notif_empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

class _CatMeta {
  final IconData icon;
  final Color color;
  final String label;
  const _CatMeta(this.icon, this.color, this.label);
}

_CatMeta _categoryMeta(NotifCategory c) {
  switch (c) {
    case NotifCategory.booking:
      return const _CatMeta(Iconsax.calendar_tick_copy, Color(0xFF3D5AFE), 'notif_cat_booking');
    case NotifCategory.promotion:
      return const _CatMeta(Iconsax.discount_shape_copy, Color(0xFFFF6D00), 'notif_cat_promotion');
    case NotifCategory.system:
      return const _CatMeta(Iconsax.security_safe_copy, Color(0xFF7C4DFF), 'notif_cat_system');
  }
}

String _formatRelative(DateTime at) {
  final diff = DateTime.now().difference(at);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${at.day}/${at.month}/${at.year}';
}

// ============================================================
// UNREAD BADGE
// ============================================================

class _UnreadBadge extends StatelessWidget {
  final int count;
  final ColorScheme cs;
  const _UnreadBadge({required this.count, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(10.r)),
      child: Text(
        '$count',
        style: TextStyle(fontSize: 11.r, color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
  }
}
