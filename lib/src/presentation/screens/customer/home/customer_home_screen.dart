import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/skeletons/home_skeleton.dart';
import 'provider/home_provider.dart';
import 'widgets/ads_carousel.dart';
import 'widgets/app_drawer.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/brands_section.dart';
import 'widgets/compact_search_bar.dart';
import 'widgets/desktop_side_nav.dart';
import 'widgets/desktop_top_bar.dart';
import 'widgets/featured_cars_section.dart';
import 'widgets/hero_banner.dart';
import 'widgets/mobile_app_bar.dart';
import 'widgets/mobile_greeting.dart';
import 'widgets/nav_items.dart';
import 'widgets/nearby_drivers_section.dart';
import 'widgets/service_row.dart';

class CustomerHomeScreen extends StatelessWidget {
  /// When provided, renders this widget in place of the home body — used by
  /// the router so /favorites, /bookings, /profile all reuse the same shell
  /// chrome (drawer + bottom-nav + desktop side-nav) while swapping the body.
  final Widget? tabBody;

  const CustomerHomeScreen({super.key, this.tabBody});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: _CustomerHomeShell(tabBody: tabBody),
    );
  }
}

class _CustomerHomeShell extends StatefulWidget {
  final Widget? tabBody;
  const _CustomerHomeShell({this.tabBody});

  @override
  State<_CustomerHomeShell> createState() => _CustomerHomeShellState();
}

class _CustomerHomeShellState extends State<_CustomerHomeShell> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _bannerAnim;
  late final Animation<double> _bannerFade;

  @override
  void initState() {
    super.initState();
    _bannerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _bannerFade = CurvedAnimation(parent: _bannerAnim, curve: Curves.easeOut);
    _bannerAnim.forward();
  }

  @override
  void dispose() {
    _bannerAnim.dispose();
    super.dispose();
  }

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  int get _currentNavIndex {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = kHomeNavItems.indexWhere((n) => n.path == loc);
    return i >= 0 ? i : 0;
  }

  int get _drawerNavIndex {
    final loc = GoRouterState.of(context).matchedLocation;
    switch (loc) {
      case '/home':
        return 0;
      case '/favorites':
        return 1;
      case '/bookings':
        return 2;
      case '/my-vehicles':
        return 3;
      case '/profile':
        return 4;
      default:
        return -1;
    }
  }

  void _goToTab(int i) => context.go(kHomeNavItems[i].path);

  void _onDrawerNav(int i) {
    _scaffoldKey.currentState?.closeDrawer();
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/favorites');
        break;
      case 2:
        context.go('/bookings');
        break;
      case 3:
        context.push('/my-vehicles');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: AppDrawer(
        isDark: _isDark,
        currentNavIndex: _drawerNavIndex,
        onNavTap: _onDrawerNav,
      ),
      drawerEnableOpenDragGesture: true,
      body: isDesktop
          ? _buildDesktopLayoutWrapper()
          : Stack(
              children: [
                _buildScreenBody(false),
                Positioned(
                  left: 24.r,
                  right: 24.r,
                  bottom: 20.r,
                  child: HomeBottomNav(
                    isDark: _isDark,
                    currentIndex: _currentNavIndex,
                    onTap: _goToTab,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDesktopLayoutWrapper() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DesktopSideNav(
          isDark: _isDark,
          currentIndex: _currentNavIndex,
          onTap: _goToTab,
        ),
        Expanded(child: _buildScreenBody(true)),
      ],
    );
  }

  Widget _buildScreenBody(bool isDesktop) {
    if (widget.tabBody != null) return widget.tabBody!;
    final isLoading = context.watch<HomeProvider>().isLoading;
    if (isLoading) return HomeSkeleton(isDesktop: isDesktop);
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        MobileAppBar(isDark: isDark),
        SliverToBoxAdapter(child: MobileGreeting(fade: _bannerFade)),
        SliverToBoxAdapter(child: CompactSearchBar(isDark: isDark)),
        SliverToBoxAdapter(child: AdsCarousel(isDark: isDark)),
        SliverToBoxAdapter(child: ServiceRow(isDark: isDark)),
        SliverToBoxAdapter(child: BrandsSection(isDark: isDark)),
        SliverToBoxAdapter(child: FeaturedCarsSection(isDark: isDark)),
        SliverToBoxAdapter(child: NearbyDriversSection(isDark: isDark)),
        SliverToBoxAdapter(child: SizedBox(height: 110.r)),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesktopTopBar(isDark: isDark),
                SizedBox(height: 28.r),
                HeroBanner(isDark: isDark, fade: _bannerFade),
                SizedBox(height: 20.r),
                AdsCarousel(isDesktop: true, isDark: isDark),
                SizedBox(height: 20.r),
                ServiceRow(isDesktop: true, isDark: isDark),
                SizedBox(height: 8.r),
                BrandsSection(isDesktop: true, isDark: isDark),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: FeaturedCarsSection(isDesktop: true, isDark: isDark)),
                    SizedBox(width: 24.r),
                    SizedBox(width: 280.r, child: NearbyDriversSection(isDesktop: true, isDark: isDark)),
                  ],
                ),
                SizedBox(height: 40.r),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
