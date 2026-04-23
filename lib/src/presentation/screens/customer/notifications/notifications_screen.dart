import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'provider/notifications_provider.dart';
import 'widgets/notif_app_bar.dart';
import 'widgets/notif_desktop_header.dart';
import 'widgets/notif_empty.dart';
import 'widgets/notif_grouped_list.dart';
import 'widgets/notif_tab_strip.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsProvider(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode ||
        (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final isDark = _isDark(context);
    final cs = Theme.of(context).colorScheme;
    final items = context.watch<NotificationsProvider>().filtered;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        NotifAppBar(isDark: isDark, cs: cs),
        SliverToBoxAdapter(child: NotifTabStrip(isDark: isDark, cs: cs)),
        ...NotifGroupedList.buildSlivers(items: items, isDark: isDark, cs: cs),
        SliverToBoxAdapter(child: SizedBox(height: 40.r)),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final isDark = _isDark(context);
    final cs = Theme.of(context).colorScheme;
    final items = context.watch<NotificationsProvider>().filtered;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 900.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotifDesktopHeader(isDark: isDark, cs: cs),
              SizedBox(height: 16.r),
              NotifTabStrip(isDark: isDark, cs: cs, compact: true),
              SizedBox(height: 8.r),
              items.isEmpty
                  ? SizedBox(height: 420.r, child: NotifEmpty(isDark: isDark, cs: cs))
                  : Column(
                      children: NotifGroupedList.buildSections(
                        items: items,
                        isDark: isDark,
                        cs: cs,
                      ),
                    ),
              SizedBox(height: 32.r),
            ],
          ),
        ),
      ),
    );
  }
}
