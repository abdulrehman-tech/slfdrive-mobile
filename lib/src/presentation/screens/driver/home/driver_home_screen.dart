import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/app_error_state.dart';
import '../shell/driver_shell_provider.dart';
import 'widgets/driver_bottom_nav.dart';
import 'widgets/driver_drawer.dart';
import 'widgets/driver_header.dart';
import 'widgets/driver_home_skeleton.dart';
import 'widgets/driver_verification_banner.dart';
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
    // The shell state is an app-lifetime singleton shared by every driver tab:
    // one dataset feeds home/trips/earnings, and actions on any tab update all
    // of them. ensureLoaded() is an idempotent no-op once fresh data exists, so
    // tab switches don't refetch; it silently refreshes stale data.
    final shell = getIt<DriverShellProvider>()..ensureLoaded();
    return ChangeNotifierProvider<DriverShellProvider>.value(
      value: shell,
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
                  Expanded(child: _buildBody(context, isDark)),
                ],
              )
            : _buildBody(context, isDark),
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

  Widget _buildBody(BuildContext context, bool isDark) {
    if (tabBody != null) return tabBody!;
    final shell = context.watch<DriverShellProvider>();
    if (shell.isInitialLoading) {
      return const DriverHomeSkeleton();
    }
    final showFullError = shell.error != null && !shell.hasData;
    return RefreshIndicator(
      onRefresh: () async {
        final provider = context.read<DriverShellProvider>();
        final messenger = ScaffoldMessenger.of(context);
        await Future.wait([
          context.read<AuthProvider>().refreshDriverStatus(),
          provider.refresh(),
        ]);
        // A failed refresh with data still on screen shouldn't blank the page —
        // surface it as a snackbar instead.
        if (provider.error != null && provider.hasData) {
          messenger.showSnackBar(SnackBar(
            content: Text(provider.error!.tr()),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          if (showFullError)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorState(
                message: shell.error,
                onRetry: shell.refresh,
                isDark: isDark,
              ),
            )
          else ...[
            SliverToBoxAdapter(child: DriverHeader(isDark: isDark)),
            SliverToBoxAdapter(child: DriverVerificationBanner(isDark: isDark)),
            SliverToBoxAdapter(child: EarningsCard(isDark: isDark)),
            SliverToBoxAdapter(child: QuickStatsRow(isDark: isDark)),
            SliverToBoxAdapter(child: TripRequestsSection(isDark: isDark)),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ],
      ),
    );
  }
}
