import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../widgets/omr_icon.dart';
import 'package:provider/provider.dart';
import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/skeletons/home_skeleton.dart';

// ============================================================
// MOCK DATA MODELS
// ============================================================

class _CarBrand {
  final String name;
  final String logoUrl;
  const _CarBrand(this.name, this.logoUrl);
}

class _CarItem {
  final String id;
  final String name;
  final String imageUrl;
  final double pricePerDay;
  final int horsepower;
  final String transmission;
  final int seats;
  final String tag;
  bool isFavourite;
  _CarItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerDay,
    required this.horsepower,
    required this.transmission,
    required this.seats,
    this.tag = '',
    this.isFavourite = false,
  });
}

class _DriverItem {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int trips;
  final String speciality;
  const _DriverItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.trips,
    required this.speciality,
  });
}

// ============================================================
// MOCK DATA
// ============================================================

final List<_CarBrand> _brands = [
  _CarBrand('Tesla', 'assets/images/brands/tesla.png'),
  _CarBrand('Mercedes', 'assets/images/brands/mercedes-benz.png'),
  _CarBrand('BMW', 'assets/images/brands/bmw.png'),
  _CarBrand('Ferrari', 'assets/images/brands/ferrari.png'),
  _CarBrand('Toyota', 'assets/images/brands/toyota.png'),
  _CarBrand('Audi', 'assets/images/brands/audi.png'),
  _CarBrand('Porsche', 'assets/images/brands/porsche.png'),
  _CarBrand('Lamborghini', 'assets/images/brands/lamborghini.png'),
];

final List<_CarItem> _featuredCars = [
  _CarItem(
    id: '1',
    name: 'Mercedes AMG GT',
    imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    pricePerDay: 250,
    horsepower: 523,
    transmission: 'Automatic',
    seats: 2,
    tag: 'Popular',
    isFavourite: true,
  ),
  _CarItem(
    id: '2',
    name: 'BMW M4 Competition',
    imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
    pricePerDay: 190,
    horsepower: 510,
    transmission: 'Automatic',
    seats: 4,
    tag: 'New',
  ),
  _CarItem(
    id: '3',
    name: 'Porsche 911 Turbo S',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    pricePerDay: 320,
    horsepower: 640,
    transmission: 'PDK',
    seats: 4,
    tag: 'Luxury',
  ),
  _CarItem(
    id: '4',
    name: 'Lamborghini Huracán',
    imageUrl: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&q=80',
    pricePerDay: 500,
    horsepower: 610,
    transmission: 'Automatic',
    seats: 2,
    tag: 'Exotic',
  ),
];

final List<_DriverItem> _nearbyDrivers = [
  _DriverItem(
    id: '1',
    name: 'Ahmed Al-Farsi',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    rating: 4.9,
    trips: 312,
    speciality: 'Chauffeur',
  ),
  _DriverItem(
    id: '2',
    name: 'Mohammed K.',
    avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    rating: 4.8,
    trips: 198,
    speciality: 'Airport',
  ),
  _DriverItem(
    id: '3',
    name: 'Yusuf Hassan',
    avatarUrl: 'https://randomuser.me/api/portraits/men/61.jpg',
    rating: 4.7,
    trips: 421,
    speciality: 'City Tours',
  ),
  _DriverItem(
    id: '4',
    name: 'Omar Saeed',
    avatarUrl: 'https://randomuser.me/api/portraits/men/77.jpg',
    rating: 4.9,
    trips: 560,
    speciality: 'Long Trips',
  ),
];

// ============================================================
// LOGOUT DIALOG HELPER
// ============================================================

void _showLogoutDialog(BuildContext context, bool isDark) {
  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 24.r,
                  offset: Offset(0, 8.r),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.logout, color: const Color(0xFFE53935), size: 32.r),
                ),
                SizedBox(height: 20.r),
                // Title
                Text(
                  'profile_logout_title'.tr(),
                  style: TextStyle(
                    fontSize: 20.r,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.r),
                // Message
                Text(
                  'profile_logout_message'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.r, color: isDark ? Colors.white70 : Colors.black54, height: 1.4),
                ),
                SizedBox(height: 24.r),
                // Buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.r),
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.04),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'profile_logout_cancel'.tr(),
                          style: TextStyle(
                            fontSize: 15.r,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.r),
                    // Logout
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (context.mounted) {
                            context.go('/auth');
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.r),
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'profile_logout_confirm'.tr(),
                          style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// MAIN SCREEN
// ============================================================

class CustomerHomeScreen extends StatefulWidget {
  /// When provided, renders this widget in place of the home body — used by
  /// the router so /favorites, /bookings, /profile all reuse the same shell
  /// chrome (drawer + bottom-nav + desktop side-nav) while swapping the body.
  final Widget? tabBody;

  const CustomerHomeScreen({super.key, this.tabBody});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedBrandIndex = -1;
  bool _isLoading = true;
  late final List<_CarItem> _cars;
  late AnimationController _bannerAnim;
  late Animation<double> _bannerFade;

  static const _navItems = [
    (Iconsax.home_2, Iconsax.home_2_copy),
    (Iconsax.heart, Iconsax.heart_copy),
    (Iconsax.calendar_2, Iconsax.calendar_2_copy),
    (Iconsax.user, Iconsax.user_copy),
  ];

  static const _navKeys = ['home', 'favorites', 'bookings', 'profile'];
  static const _navPaths = ['/home', '/favorites', '/bookings', '/profile'];

  int get _currentNavIndex {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _navPaths.indexOf(loc);
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

  void _goToTab(int i) => context.go(_navPaths[i]);

  @override
  void initState() {
    super.initState();
    _cars = List<_CarItem>.from(_featuredCars);
    _bannerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _bannerFade = CurvedAnimation(parent: _bannerAnim, curve: Curves.easeOut);
    _bannerAnim.forward();

    // Simulate loading for 1.5 seconds then show content
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
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

  Widget _buildScreenBody(bool isDesktop) {
    // When the router hands us a tab body (e.g. FavoritesScreen for /favorites),
    // render that instead of the home content. The home-only skeleton and
    // banner animation stay tied to the home body only.
    if (widget.tabBody != null) return widget.tabBody!;
    if (_isLoading) {
      return HomeSkeleton(isDesktop: isDesktop);
    }
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _AppDrawer(
        isDark: _isDark,
        currentNavIndex: _drawerNavIndex,
        onNavTap: (i) {
          _scaffoldKey.currentState?.closeDrawer();
          // Drawer has 5 items: home, favorites, bookings, my_vehicles, profile.
          // All but my_vehicles are shell tabs; my_vehicles pushes a placeholder.
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
        },
      ),
      drawerEnableOpenDragGesture: true,
      body: isDesktop
          ? _buildDesktopLayoutWrapper()
          : Stack(
              children: [
                _buildScreenBody(false),
                Positioned(left: 24.r, right: 24.r, bottom: 20.r, child: _buildBottomNav()),
              ],
            ),
    );
  }

  Widget _buildDesktopLayoutWrapper() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDesktopSideNav(),
        Expanded(child: _buildScreenBody(true)),
      ],
    );
  }

  // ==========================================================================
  // MOBILE LAYOUT
  // ==========================================================================

  Widget _buildMobileLayout() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildMobileAppBar(),
        SliverToBoxAdapter(child: _buildHeroBanner()),
        SliverToBoxAdapter(child: _buildServiceRow()),
        SliverToBoxAdapter(child: _buildBrandsSection()),
        SliverToBoxAdapter(child: _buildFeaturedCarsSection()),
        SliverToBoxAdapter(child: _buildNearbyDriversSection()),
        SliverToBoxAdapter(child: SizedBox(height: 110.r)),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT
  // ==========================================================================

  Widget _buildDesktopLayout() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDesktopTopBar(),
                SizedBox(height: 28.r),
                _buildHeroBanner(isDesktop: true),
                SizedBox(height: 28.r),
                _buildServiceRow(isDesktop: true),
                SizedBox(height: 8.r),
                _buildBrandsSection(isDesktop: true),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFeaturedCarsSection(isDesktop: true)),
                    SizedBox(width: 24.r),
                    SizedBox(width: 280.r, child: _buildNearbyDriversSection(isDesktop: true)),
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

  // ==========================================================================
  // MOBILE APP BAR (SliverAppBar)
  // ==========================================================================

  Widget _buildMobileAppBar() {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;

    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 0,
      toolbarHeight: 64.r,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
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
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.r),
        child: Row(
          children: [
            // Location
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/profile/addresses'),
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Iconsax.location_copy, color: cs.primary, size: 16.r),
                    ),
                    SizedBox(width: 8.r),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'home_location_label'.tr(),
                            style: TextStyle(
                              fontSize: 10.r,
                              color: cs.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'home_location'.tr(),
                                style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                              ),
                              SizedBox(width: 3.r),
                              Icon(CupertinoIcons.chevron_down, size: 12.r, color: cs.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Theme toggle
            _ThemeToggleBtn(isDark: isDark),
            SizedBox(width: 8.r),
            // Notification bell
            _NotificationBtn(cs: cs, isDark: isDark),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // DESKTOP TOP BAR
  // ==========================================================================

  Widget _buildDesktopTopBar() {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;

    return Row(
      children: [
        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home_greeting'.tr(),
                style: TextStyle(
                  fontSize: 13.r,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.r),
              Text(
                'home_headline'.tr(),
                style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
              ),
            ],
          ),
        ),
        // Search
        _buildSearchField(width: 320.r),
        SizedBox(width: 16.r),
        _ThemeToggleBtn(isDark: isDark),
        SizedBox(width: 12.r),
        _NotificationBtn(cs: cs, isDark: isDark),
      ],
    );
  }

  // ==========================================================================
  // HERO BANNER
  // ==========================================================================

  Widget _buildHeroBanner({bool isDesktop = false}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;

    return FadeTransition(
      opacity: _bannerFade,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isDesktop ? 0 : 16.r,
          isDesktop ? 0 : 16.r,
          isDesktop ? 0 : 16.r,
          isDesktop ? 0 : 8.r,
        ),
        height: isDesktop ? 200.r : 210.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A237E), const Color(0xFF4A148C)]
                : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.3 : 0.25),
              blurRadius: 24.r,
              offset: Offset(0, 8.r),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30.r,
              top: -30.r,
              child: Container(
                width: 160.r,
                height: 160.r,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            Positioned(
              right: 60.r,
              bottom: -40.r,
              child: Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
              ),
            ),
            // Search bar (mobile only) — inside banner
            if (!isDesktop) Positioned(bottom: 16.r, left: 16.r, right: 16.r, child: _buildSearchField()),
            // Text
            Padding(
              padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, isDesktop ? 20.r : 76.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 3.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF69FF47)),
                        ),
                        SizedBox(width: 5.r),
                        Text(
                          'home_available_now'.tr(),
                          style: TextStyle(color: Colors.white, fontSize: 10.r, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    'home_greeting'.tr(),
                    style: TextStyle(
                      fontSize: isDesktop ? 14.r : 12.r,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 3.r),
                  Text(
                    'home_headline'.tr(),
                    style: TextStyle(
                      fontSize: isDesktop ? 20.r : 18.r,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SEARCH FIELD
  // ==========================================================================

  Widget _buildSearchField({double? width}) {
    final isDark = _isDark;

    final child = ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 52.r,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 14.r),
              Icon(Iconsax.search_normal_copy, color: isDark ? Colors.white54 : const Color(0xFFAAAAAA), size: 20.r),
              SizedBox(width: 10.r),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.pushNamed('search'),
                  child: AbsorbPointer(
                    child: Text(
                      'home_search_hint'.tr(),
                      style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFFAAAAAA), fontSize: 14.r),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed('search'),
                child: Container(
                  margin: EdgeInsets.all(6.r),
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0C2485), Color(0xFF677EF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                        blurRadius: 10.r,
                        offset: Offset(0, 3.r),
                      ),
                    ],
                  ),
                  child: Icon(Iconsax.setting_4_copy, color: Colors.white, size: 18.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return child;
  }

  // ==========================================================================
  // SERVICE ROW
  // ==========================================================================

  Widget _buildServiceRow({bool isDesktop = false}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;

    final services = [
      (Iconsax.car_copy, 'service_rent_car', const Color(0xFF3D5AFE), const Color(0xFFE8EAFF)),
      (Iconsax.driver_copy, 'service_car_driver', const Color(0xFF7C4DFF), const Color(0xFFF3EEFF)),
      (Iconsax.profile_2user_copy, 'service_hire_driver', const Color(0xFF00BCD4), const Color(0xFFE0F7FA)),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 0 : 16.r, 12.r, isDesktop ? 0 : 16.r, 4.r),
      child: Row(
        children: services.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final iconColor = s.$3;
          final bgLight = s.$4;
          final bgDark = iconColor.withValues(alpha: 0.15);

          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: i < services.length - 1 ? 10.r : 0),
              child: GestureDetector(
                onTap: () {
                  if (i == 0) {
                    context.pushNamed('car-listing');
                  } else if (i == 1) {
                    context.pushNamed('car-listing');
                  } else {
                    context.pushNamed('driver-listing');
                  }
                },
                child: _GlassCard(
                  isDark: isDark,
                  borderRadius: 18.r,
                  padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 10.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: isDark ? bgDark : bgLight,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Icon(s.$1, color: isDark ? iconColor.withValues(alpha: 0.9) : iconColor, size: 24.r),
                      ),
                      SizedBox(height: 10.r),
                      Text(
                        s.$2.tr(),
                        style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: cs.onSurface, height: 1.3),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================================
  // BRANDS SECTION
  // ==========================================================================

  Widget _buildBrandsSection({bool isDesktop = false}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'home_all_brands'.tr(),
          cs: cs,
          onViewAll: () => context.pushNamed('brands'),
          isDesktop: isDesktop,
        ),
        SizedBox(
          height: 98.r,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16.r),
            itemCount: _brands.length,
            itemBuilder: (_, i) {
              final brand = _brands[i];
              final selected = _selectedBrandIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedBrandIndex = selected ? -1 : i);
                  context.pushNamed('car-listing', extra: {'brand': brand.name});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: EdgeInsetsDirectional.only(end: 14.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 58.r,
                        height: 58.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? (selected ? cs.primary.withValues(alpha: 0.15) : const Color(0xFF1E1E2E))
                              : (selected ? cs.primary.withValues(alpha: 0.08) : Colors.white),
                          border: Border.all(
                            color: selected
                                ? cs.primary
                                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
                            width: selected ? 2.5 : 1.5,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.25),
                                    blurRadius: 12.r,
                                    offset: Offset(0, 4.r),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                    blurRadius: 8.r,
                                    offset: Offset(0, 2.r),
                                  ),
                                ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Image.asset(
                              brand.logoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  brand.name[0],
                                  style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.primary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.r),
                      Text(
                        brand.name,
                        style: TextStyle(
                          fontSize: 10.r,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // FEATURED CARS
  // ==========================================================================

  Widget _buildFeaturedCarsSection({bool isDesktop = false}) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'home_all_collections'.tr(),
          cs: cs,
          onViewAll: () => context.pushNamed('car-listing'),
          isDesktop: isDesktop,
        ),
        if (isDesktop)
          // Vertical list for desktop side-panel
          ...List.generate(
            _cars.length,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 16.r),
              child: _CarCard(
                car: _cars[i],
                isDark: _isDark,
                cs: cs,
                onFavourite: () => setState(() => _cars[i].isFavourite = !_cars[i].isFavourite),
                onTap: () => context.pushNamed('car-detail', pathParameters: {'id': _cars[i].id}),
              ),
            ),
          )
        else
          // Horizontal scroll for mobile
          SizedBox(
            height: 270.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              itemCount: _cars.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsetsDirectional.only(end: 16.r),
                child: SizedBox(
                  width: 220.r,
                  child: _CarCard(
                    car: _cars[i],
                    isDark: _isDark,
                    cs: cs,
                    onFavourite: () => setState(() => _cars[i].isFavourite = !_cars[i].isFavourite),
                    onTap: () => context.pushNamed('car-detail', pathParameters: {'id': _cars[i].id}),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // NEARBY DRIVERS
  // ==========================================================================

  Widget _buildNearbyDriversSection({bool isDesktop = false}) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'home_nearby_drivers'.tr(),
          cs: cs,
          onViewAll: () => context.pushNamed('driver-listing'),
          isDesktop: isDesktop,
        ),
        if (isDesktop)
          ..._nearbyDrivers.map(
            (d) => Padding(
              padding: EdgeInsets.only(bottom: 12.r),
              child: _DriverCard(
                driver: d,
                isDark: _isDark,
                cs: cs,
                horizontal: true,
                onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': d.id}),
              ),
            ),
          )
        else
          SizedBox(
            height: 168.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              itemCount: _nearbyDrivers.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsetsDirectional.only(end: 12.r),
                child: _DriverCard(
                  driver: _nearbyDrivers[i],
                  isDark: _isDark,
                  cs: cs,
                  onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': _nearbyDrivers[i].id}),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP SIDE NAV
  // ==========================================================================

  Widget _buildDesktopSideNav() {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 84.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111118) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 40.r),
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(color: cs.primary.withValues(alpha: 0.4), blurRadius: 12.r, offset: Offset(0, 4.r)),
              ],
            ),
            child: Icon(Iconsax.car_copy, color: Colors.white, size: 22.r),
          ),
          SizedBox(height: 36.r),
          ...List.generate(_navItems.length, (i) {
            final active = _currentNavIndex == i;
            return GestureDetector(
              onTap: () => _goToTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.r),
                decoration: BoxDecoration(
                  color: active ? cs.primary.withValues(alpha: isDark ? 0.12 : 0.07) : Colors.transparent,
                  border: active
                      ? Border(
                          left: BorderSide(color: cs.primary, width: 3.r),
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      active ? _navItems[i].$2 : _navItems[i].$1,
                      color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.45),
                      size: 22.r,
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      _navKeys[i].tr(),
                      style: TextStyle(
                        fontSize: 9.r,
                        color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.45),
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 24.r),
            child: _ThemeToggleBtn(isDark: isDark, vertical: true),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTTOM NAV (mobile)
  // ==========================================================================

  Widget _buildBottomNav() {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 64.r,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(32.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.10),
                blurRadius: 28.r,
                spreadRadius: -2,
                offset: Offset(0, 8.r),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final active = _currentNavIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _goToTab(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 5.r),
                        decoration: BoxDecoration(
                          color: active ? cs.primary.withValues(alpha: isDark ? 0.25 : 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          active ? _navItems[i].$2 : _navItems[i].$1,
                          color: active ? cs.primary : cs.onSurface.withValues(alpha: isDark ? 0.35 : 0.4),
                          size: 22.r,
                        ),
                      ),
                      SizedBox(height: 2.r),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 10.r,
                          color: active ? cs.primary : cs.onSurface.withValues(alpha: isDark ? 0.35 : 0.4),
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                        ),
                        child: Text(_navKeys[i].tr()),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GLASS CARD HELPER
// ============================================================

class _GlassCard extends StatelessWidget {
  final bool isDark;
  final double borderRadius;
  final EdgeInsets? padding;
  final Widget child;
  final Color? borderColor;

  const _GlassCard({required this.isDark, required this.child, this.borderRadius = 20, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color:
                  borderColor ?? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme cs;
  final VoidCallback onViewAll;
  final bool isDesktop;

  const _SectionHeader({required this.title, required this.cs, required this.onViewAll, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 0 : 16.r, 20.r, isDesktop ? 0 : 16.r, 12.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface, letterSpacing: -0.2),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 5.r),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'home_view_all'.tr(),
                style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CAR CARD
// ============================================================

class _CarCard extends StatelessWidget {
  final _CarItem car;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onFavourite;
  final VoidCallback? onTap;

  const _CarCard({required this.car, required this.isDark, required this.cs, required this.onFavourite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        isDark: isDark,
        borderRadius: 20.r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
                  child: CachedNetworkImage(
                    imageUrl: car.imageUrl,
                    height: 150.r,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 150.r,
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                      child: Center(
                        child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.4), size: 36.r),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 150.r,
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                      child: Center(
                        child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.4), size: 36.r),
                      ),
                    ),
                  ),
                ),
                // Tag badge
                if (car.tag.isNotEmpty)
                  Positioned(
                    top: 10.r,
                    left: 10.r,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(8.r)),
                      child: Text(
                        car.tag,
                        style: TextStyle(fontSize: 10.r, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                // Favourite
                Positioned(
                  top: 10.r,
                  right: 10.r,
                  child: GestureDetector(
                    onTap: onFavourite,
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        car.isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                        color: car.isFavourite ? Colors.redAccent : (isDark ? Colors.white60 : Colors.black45),
                        size: 16.r,
                      ),
                    ),
                  ),
                ),
                // Price overlay
                Positioned(
                  bottom: 10.r,
                  right: 10.r,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            OmrIcon(size: 12.r, color: Colors.white),
                            SizedBox(width: 3.r),
                            Text(
                              '${car.pricePerDay.toInt()}/${'day'.tr()}',
                              style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.r),
                  Row(
                    children: [
                      _SpecPill(icon: Iconsax.flash_1_copy, label: '${car.horsepower}hp', isDark: isDark, cs: cs),
                      SizedBox(width: 6.r),
                      _SpecPill(icon: Iconsax.setting_copy, label: car.transmission, isDark: isDark, cs: cs),
                      SizedBox(width: 6.r),
                      _SpecPill(icon: Iconsax.people_copy, label: '${car.seats}', isDark: isDark, cs: cs),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SPEC PILL
// ============================================================

class _SpecPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final ColorScheme cs;

  const _SpecPill({required this.icon, required this.label, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
          SizedBox(width: 4.r),
          Text(
            label,
            style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DRIVER CARD
// ============================================================

class _DriverCard extends StatelessWidget {
  final _DriverItem driver;
  final bool isDark;
  final ColorScheme cs;
  final bool horizontal;
  final VoidCallback? onTap;

  const _DriverCard({
    required this.driver,
    required this.isDark,
    required this.cs,
    this.horizontal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (horizontal) return _buildHorizontal();
    return _buildVertical();
  }

  Widget _buildVertical() {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        isDark: isDark,
        borderRadius: 18,
        padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: 10.r),
        child: SizedBox(
          width: 110.r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _avatar(28.r),
                  Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF1A1A2A) : Colors.white, width: 1.5),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.r),
              Text(
                driver.name.split(' ').first,
                style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3.r),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  driver.speciality,
                  style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 4.r),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 11.r),
                  SizedBox(width: 2.r),
                  Text(
                    driver.rating.toString(),
                    style: TextStyle(
                      fontSize: 11.r,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontal() {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        isDark: isDark,
        borderRadius: 14,
        padding: EdgeInsets.all(12.r),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                _avatar(24.r),
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? const Color(0xFF1A1A2A) : Colors.white, width: 1.5),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.r),
                  Row(
                    children: [
                      Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 11.r),
                      SizedBox(width: 2.r),
                      Text(
                        '${driver.rating}  ·  ${driver.trips} trips',
                        style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Text(
                'available'.tr(),
                style: TextStyle(fontSize: 10.r, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(double radius) {
    return CachedNetworkImage(
      imageUrl: driver.avatarUrl,
      imageBuilder: (_, img) => CircleAvatar(radius: radius, backgroundImage: img),
      placeholder: (_, __) => CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
        child: Icon(Iconsax.user_copy, size: radius * 0.8, color: cs.primary.withValues(alpha: 0.5)),
      ),
      errorWidget: (_, __, ___) => CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
        child: Icon(Iconsax.user_copy, size: radius * 0.8, color: cs.primary.withValues(alpha: 0.5)),
      ),
    );
  }
}

// ============================================================
// THEME TOGGLE BUTTON
// ============================================================

class _ThemeToggleBtn extends StatelessWidget {
  final bool isDark;
  final bool vertical;
  const _ThemeToggleBtn({required this.isDark, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
      child: Container(
        width: vertical ? 44.r : 38.r,
        height: vertical ? 44.r : 38.r,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            isDark ? Iconsax.sun_1 : Iconsax.moon,
            key: ValueKey(isDark),
            color: isDark ? const Color(0xFFFFC107) : cs.onSurface.withValues(alpha: 0.6),
            size: 18.r,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NOTIFICATION BUTTON
// ============================================================

class _NotificationBtn extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;
  const _NotificationBtn({required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed('notifications'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
              ),
            ),
            child: Icon(Iconsax.notification_copy, color: cs.onSurface.withValues(alpha: 0.7), size: 18.r),
          ),
          // Red badge dot
          Positioned(
            top: -1.r,
            right: -1.r,
            child: Container(
              width: 9.r,
              height: 9.r,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF0F0F18) : Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// APP DRAWER
// ============================================================

class _AppDrawer extends StatelessWidget {
  final bool isDark;
  final int currentNavIndex;
  final void Function(int) onNavTap;

  const _AppDrawer({required this.isDark, required this.currentNavIndex, required this.onNavTap});

  static const _navItems = [
    (Iconsax.home_2_copy, Iconsax.home_2, 'home'),
    (Iconsax.heart_copy, Iconsax.heart, 'favorites'),
    (Iconsax.calendar_2_copy, Iconsax.calendar_2, 'bookings'),
    (Iconsax.car_copy, Iconsax.car, 'my_vehicles'),
    (Iconsax.user_copy, Iconsax.user, 'profile'),
  ];

  static const _navColors = [
    Color(0xFF3D5AFE),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFF7C4DFF),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surfaceBg = isDark ? const Color(0xFF0F0F18) : const Color(0xFFF7F8FC);
    final cardBg = isDark ? const Color(0xFF1A1A28) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.06);

    return Drawer(
      width: 295.r,
      backgroundColor: surfaceBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(28.r), bottomRight: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          _DrawerHeader(isDark: isDark, cs: cs, cardBg: cardBg, borderCol: borderCol),

          // ── Stats Row ────────────────────────────────────────
          _DrawerStats(isDark: isDark, cs: cs, cardBg: cardBg, borderCol: borderCol),

          SizedBox(height: 8.r),

          // ── Nav Items ────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
              itemCount: _navItems.length,
              itemBuilder: (_, i) {
                final item = _navItems[i];
                final active = currentNavIndex == i;
                final col = _navColors[i];

                return GestureDetector(
                  onTap: () => onNavTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.only(bottom: 6.r),
                    padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 13.r),
                    decoration: BoxDecoration(
                      color: active ? col.withValues(alpha: isDark ? 0.18 : 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                      border: active ? Border.all(color: col.withValues(alpha: 0.25), width: 1) : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: active
                                ? col.withValues(alpha: isDark ? 0.22 : 0.14)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            active ? item.$1 : item.$2,
                            color: active ? col : cs.onSurface.withValues(alpha: 0.45),
                            size: 19.r,
                          ),
                        ),
                        SizedBox(width: 12.r),
                        Expanded(
                          child: Text(
                            item.$3.tr(),
                            style: TextStyle(
                              fontSize: 14.r,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? col : cs.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                        if (active)
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Bottom ───────────────────────────────────────────
          _DrawerBottom(isDark: isDark, cs: cs, borderCol: borderCol),
        ],
      ),
    );
  }
}

// ── Drawer Header ────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final Color cardBg;
  final Color borderCol;

  const _DrawerHeader({required this.isDark, required this.cs, required this.cardBg, required this.borderCol});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.r, 56.r, 20.r, 20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative blobs
          Positioned(
            right: -10.r,
            top: -20.r,
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          Positioned(
            right: 30.r,
            bottom: -30.r,
            child: Container(
              width: 70.r,
              height: 70.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)),
            ),
          ),
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 58.r,
                    height: 58.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.r),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: const Color(0xFF0C2485)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2.r,
                    right: 2.r,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home_greeting'.tr(),
                      style: TextStyle(fontSize: 11.r, color: Colors.white60, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 3.r),
                    Text(
                      'Guest User',
                      style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 5.r),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.medal_star_copy, color: const Color(0xFFFFC107), size: 12.r),
                          SizedBox(width: 4.r),
                          Text(
                            'drawer_guest_badge'.tr(),
                            style: TextStyle(fontSize: 9.r, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Drawer Stats Row ─────────────────────────────────────────

class _DrawerStats extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final Color cardBg;
  final Color borderCol;

  const _DrawerStats({required this.isDark, required this.cs, required this.cardBg, required this.borderCol});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (Iconsax.car_copy, '0', 'drawer_trips', const Color(0xFF3D5AFE)),
      (Iconsax.heart_copy, '0', 'drawer_saved', const Color(0xFFE91E63)),
      (Iconsax.star_1_copy, '—', 'drawer_rating', const Color(0xFFFFC107)),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 4.r),
            ),
          ],
        ),
        child: Row(
          children: stats.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.r),
                decoration: BoxDecoration(
                  border: i < stats.length - 1 ? Border(right: BorderSide(color: borderCol)) : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.$1, color: s.$4, size: 18.r),
                    SizedBox(height: 4.r),
                    Text(
                      s.$2,
                      style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      s.$3.tr(),
                      style: TextStyle(
                        fontSize: 9.r,
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Drawer Bottom ────────────────────────────────────────────

class _DrawerBottom extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final Color borderCol;

  const _DrawerBottom({required this.isDark, required this.cs, required this.borderCol});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 28.r),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderCol)),
      ),
      child: Column(
        children: [
          // Theme toggle row
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                _ThemePill(
                  label: 'theme_light'.tr(),
                  icon: Iconsax.sun_1,
                  active: !isDark,
                  activeColor: const Color(0xFFFFC107),
                  onTap: () => context.read<ThemeProvider>().setLightMode(),
                  isDark: isDark,
                ),
                _ThemePill(
                  label: 'theme_dark'.tr(),
                  icon: Iconsax.moon,
                  active: isDark,
                  activeColor: const Color(0xFF7C4DFF),
                  onTap: () => context.read<ThemeProvider>().setDarkMode(),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.r),
          // Sign in / out button
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Close drawer first
              _showLogoutDialog(context, isDark);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.logout, color: const Color(0xFFE53935), size: 18.r),
                  SizedBox(width: 8.r),
                  Text(
                    'drawer_sign_out'.tr(),
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: const Color(0xFFE53935)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theme Pill ───────────────────────────────────────────────

class _ThemePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemePill({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: 10.r),
          decoration: BoxDecoration(
            color: active ? activeColor.withValues(alpha: isDark ? 0.2 : 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15.r, color: active ? activeColor : cs.onSurface.withValues(alpha: 0.4)),
              SizedBox(width: 6.r),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.r,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? activeColor : cs.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
