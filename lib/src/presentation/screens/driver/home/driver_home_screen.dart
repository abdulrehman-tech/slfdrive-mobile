import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import 'provider/driver_home_provider.dart';
import 'widgets/driver_bottom_nav.dart';
import 'widgets/driver_drawer.dart';
import 'widgets/driver_header.dart';
import 'widgets/earnings_card.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/trip_requests_section.dart';

class DriverHomeScreen extends StatelessWidget {
  /// When provided, renders this widget in place of the home body — used by
  /// the router so /driver/earnings, /driver/trips, /driver/profile reuse the
  /// same shell chrome while swapping the body.
  final Widget? tabBody;

  const DriverHomeScreen({super.key, this.tabBody});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverHomeProvider(),
      child: _DriverHomeView(tabBody: tabBody),
    );
  }
}

class _DriverHomeView extends StatelessWidget {
  final Widget? tabBody;

  const _DriverHomeView({this.tabBody});

  static const _navPaths = ['/driver/home', '/driver/earnings', '/driver/trips', '/driver/profile'];

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _navPaths.indexOf(loc);
    return i >= 0 ? i : 0;
  }

  int _drawerSelectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    switch (loc) {
      case '/driver/home':
        return 0;
      case '/driver/earnings':
        return 1;
      case '/driver/trips':
        return 2;
      case '/driver/profile':
        return 3;
      case '/help':
        return 4;
      default:
        return -1;
    }
  }

  void _goToTab(BuildContext context, int i) => context.go(_navPaths[i]);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= Breakpoints.desktop;
    final selectedIndex = _selectedIndex(context);
    final drawerSelectedIndex = _drawerSelectedIndex(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      drawer: isDesktop
          ? null
          : DriverMobileDrawer(
              isDark: isDark,
              drawerSelectedIndex: drawerSelectedIndex,
              onTabSelect: (i) => _goToTab(context, i),
            ),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  DriverDesktopDrawer(
                    isDark: isDark,
                    drawerSelectedIndex: drawerSelectedIndex,
                    onTabSelect: (i) => _goToTab(context, i),
                  ),
                  Expanded(child: _buildBody(isDark)),
                ],
              )
            : _buildBody(isDark),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : DriverBottomNav(
              isDark: isDark,
              selectedIndex: selectedIndex,
              onSelect: (i) => _goToTab(context, i),
            ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (tabBody != null) return tabBody!;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: DriverHeader(isDark: isDark)),
        SliverToBoxAdapter(child: EarningsCard(isDark: isDark)),
        SliverToBoxAdapter(child: QuickStatsRow(isDark: isDark)),
        SliverToBoxAdapter(child: TripRequestsSection(isDark: isDark)),
        SliverToBoxAdapter(child: SizedBox(height: 100.r)),
      ],
    );
  }
}
