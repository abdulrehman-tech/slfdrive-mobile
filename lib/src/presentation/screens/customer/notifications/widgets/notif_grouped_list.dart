import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/notif_item.dart';
import 'notif_age_header.dart';
import 'notif_empty.dart';
import 'notif_tile.dart';

/// Groups notifications by NotifAge and builds slivers (mobile) or a
/// list of widgets (desktop) using the tile + age-header widgets.
class NotifGroupedList {
  static List<Widget> buildSlivers({
    required List<NotifItem> items,
    required bool isDark,
    required ColorScheme cs,
  }) {
    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: NotifEmpty(isDark: isDark, cs: cs),
        ),
      ];
    }

    final groups = _groupByAge(items);
    final slivers = <Widget>[];
    for (final age in NotifAge.values) {
      final entries = groups[age];
      if (entries == null || entries.isEmpty) continue;
      slivers.add(
        SliverToBoxAdapter(
          child: NotifAgeHeader(
            labelKey: ageLabelKey(age),
            cs: cs,
            padding: EdgeInsets.fromLTRB(20.r, 18.r, 16.r, 8.r),
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
              child: NotifTile(item: entries[i], isDark: isDark, cs: cs),
            ),
          ),
        ),
      );
    }
    return slivers;
  }

  static List<Widget> buildSections({
    required List<NotifItem> items,
    required bool isDark,
    required ColorScheme cs,
  }) {
    final groups = _groupByAge(items);
    final widgets = <Widget>[];
    for (final age in NotifAge.values) {
      final entries = groups[age];
      if (entries == null || entries.isEmpty) continue;
      widgets.add(
        NotifAgeHeader(
          labelKey: ageLabelKey(age),
          cs: cs,
          padding: EdgeInsets.fromLTRB(4.r, 18.r, 0, 8.r),
        ),
      );
      widgets.addAll(
        entries.map(
          (e) => Padding(
            padding: EdgeInsets.only(bottom: 10.r),
            child: NotifTile(item: e, isDark: isDark, cs: cs),
          ),
        ),
      );
    }
    return widgets;
  }

  static Map<NotifAge, List<NotifItem>> _groupByAge(List<NotifItem> items) {
    final groups = <NotifAge, List<NotifItem>>{};
    for (final n in items) {
      groups.putIfAbsent(n.age, () => []).add(n);
    }
    return groups;
  }
}
