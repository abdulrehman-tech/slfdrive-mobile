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

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Seeing the list counts as seeing the notifications: drop them from the
    // system tray so the launcher badge doesn't keep claiming they're pending.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationsProvider>().onInboxOpened();
    });
  }

  // NotificationsProvider is an app-lifetime singleton supplied by the root
  // MultiProvider — the inbox and its unread badge are shared with the home
  // app bar and with pushes arriving while another screen is on top.
  @override
  Widget build(BuildContext context) => const _NotificationsView();
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
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

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.r),
            child: NotifTabStrip(isDark: isDark, cs: cs),
          ),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 32.r),
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
                  ? SizedBox(
                      height: 420.r,
                      child: NotifEmpty(isDark: isDark, cs: cs),
                    )
                  : Column(
                      children: NotifGroupedList.buildSections(items: items, isDark: isDark, cs: cs),
                    ),
              SizedBox(height: 32.r),
            ],
          ),
        ),
      ),
    );
  }
}
