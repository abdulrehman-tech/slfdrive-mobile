import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../../widgets/omr_icon.dart';
import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';

// ============================================================
// MOCK DATA
// ============================================================

class _FavCar {
  final String id;
  final String name;
  final String imageUrl;
  final double pricePerDay;
  final String brand;
  final double rating;
  _FavCar({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerDay,
    required this.brand,
    required this.rating,
  });
}

class _FavDriver {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int trips;
  final String speciality;
  _FavDriver({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.trips,
    required this.speciality,
  });
}

final List<_FavCar> _mockFavCars = [
  _FavCar(
    id: '1',
    name: 'Mercedes AMG GT',
    imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    pricePerDay: 250,
    brand: 'Mercedes',
    rating: 4.9,
  ),
  _FavCar(
    id: '2',
    name: 'BMW M4 Competition',
    imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
    pricePerDay: 190,
    brand: 'BMW',
    rating: 4.8,
  ),
  _FavCar(
    id: '3',
    name: 'Porsche 911 Turbo S',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    pricePerDay: 320,
    brand: 'Porsche',
    rating: 4.9,
  ),
];

final List<_FavDriver> _mockFavDrivers = [
  _FavDriver(
    id: '1',
    name: 'Ahmed Al-Farsi',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    rating: 4.9,
    trips: 312,
    speciality: 'Chauffeur',
  ),
  _FavDriver(
    id: '2',
    name: 'Mohammed K.',
    avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    rating: 4.8,
    trips: 198,
    speciality: 'Airport',
  ),
];

// ============================================================
// FAVORITES SCREEN
// ============================================================

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _filterIndex = 0; // 0=All, 1=Cars, 2=Drivers
  late List<_FavCar> _cars;
  late List<_FavDriver> _drivers;

  static const _filters = ['favorites_filter_all', 'favorites_filter_cars', 'favorites_filter_drivers'];
  static const _filterIcons = [Iconsax.heart_copy, Iconsax.car_copy, Iconsax.profile_2user_copy];
  static const _filterColors = [Color(0xFF3D5AFE), Color(0xFF7C4DFF), Color(0xFF00BCD4)];

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  void initState() {
    super.initState();
    _cars = List.from(_mockFavCars);
    _drivers = List.from(_mockFavDrivers);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  // ==========================================================================
  // MOBILE LAYOUT
  // ==========================================================================

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    final showCars = _filterIndex == 0 || _filterIndex == 1;
    final showDrivers = _filterIndex == 0 || _filterIndex == 2;
    final isEmpty = (showCars ? _cars.isEmpty : true) && (showDrivers ? _drivers.isEmpty : true);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App bar
        SliverAppBar(
          pinned: true,
          floating: false,
          expandedHeight: 0,
          toolbarHeight: 64.r,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
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
                Text(
                  'favorites_title'.tr(),
                  style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                const Spacer(),
                // Search icon
                GestureDetector(
                  onTap: () {},
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
                    child: Icon(Iconsax.search_normal_1, color: cs.onSurface.withValues(alpha: 0.6), size: 18.r),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Filter chips
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 8.r),
            child: Row(
              children: _filters.asMap().entries.map((e) {
                final i = e.key;
                final active = _filterIndex == i;
                final col = _filterColors[i];
                return Padding(
                  padding: EdgeInsets.only(right: 10.r),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                      decoration: BoxDecoration(
                        color: active
                            ? col.withValues(alpha: isDark ? 0.2 : 0.12)
                            : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(14.r),
                        border: active ? Border.all(color: col.withValues(alpha: 0.3)) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_filterIcons[i], size: 15.r, color: active ? col : cs.onSurface.withValues(alpha: 0.5)),
                          SizedBox(width: 6.r),
                          Text(
                            e.value.tr(),
                            style: TextStyle(
                              fontSize: 12.r,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? col : cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Content
        if (isEmpty)
          SliverFillRemaining(
            child: _EmptyFavorites(isDark: isDark, cs: cs),
          )
        else ...[
          // Cars
          if (showCars && _cars.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: 14.r),
                    child: _FavCarCard(
                      car: _cars[i],
                      isDark: isDark,
                      cs: cs,
                      onRemove: () => setState(() => _cars.removeAt(i)),
                      onTap: () => context.pushNamed('car-detail', pathParameters: {'id': _cars[i].id}),
                    ),
                  ),
                  childCount: _cars.length,
                ),
              ),
            ),
          // Drivers
          if (showDrivers && _drivers.isNotEmpty) ...[
            if (showCars && _cars.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 12.r),
                  child: Row(
                    children: [
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Iconsax.profile_2user_copy, color: const Color(0xFF00BCD4), size: 14.r),
                      ),
                      SizedBox(width: 8.r),
                      Text(
                        'favorites_filter_drivers'.tr(),
                        style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: 12.r),
                    child: _FavDriverCard(
                      driver: _drivers[i],
                      isDark: isDark,
                      cs: cs,
                      onRemove: () => setState(() => _drivers.removeAt(i)),
                      onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': _drivers[i].id}),
                    ),
                  ),
                  childCount: _drivers.length,
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 100.r)),
        ],
      ],
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT
  // ==========================================================================

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    final showCars = _filterIndex == 0 || _filterIndex == 1;
    final showDrivers = _filterIndex == 0 || _filterIndex == 2;
    final isEmpty = (showCars ? _cars.isEmpty : true) && (showDrivers ? _drivers.isEmpty : true);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + filters
              Row(
                children: [
                  Text(
                    'favorites_title'.tr(),
                    style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                  SizedBox(width: 24.r),
                  ..._filters.asMap().entries.map((e) {
                    final i = e.key;
                    final active = _filterIndex == i;
                    final col = _filterColors[i];
                    return Padding(
                      padding: EdgeInsets.only(right: 10.r),
                      child: GestureDetector(
                        onTap: () => setState(() => _filterIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                          decoration: BoxDecoration(
                            color: active
                                ? col.withValues(alpha: isDark ? 0.2 : 0.12)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(14.r),
                            border: active ? Border.all(color: col.withValues(alpha: 0.3)) : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _filterIcons[i],
                                size: 15.r,
                                color: active ? col : cs.onSurface.withValues(alpha: 0.5),
                              ),
                              SizedBox(width: 6.r),
                              Text(
                                e.value.tr(),
                                style: TextStyle(
                                  fontSize: 12.r,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                  color: active ? col : cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 24.r),
              if (isEmpty)
                SizedBox(
                  height: 400.r,
                  child: _EmptyFavorites(isDark: isDark, cs: cs),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cars grid
                    if (showCars)
                      Expanded(
                        flex: 3,
                        child: Wrap(
                          spacing: 16.r,
                          runSpacing: 16.r,
                          children: _cars.asMap().entries.map((e) {
                            return SizedBox(
                              width: 320.r,
                              child: _FavCarCard(
                                car: e.value,
                                isDark: isDark,
                                cs: cs,
                                onRemove: () => setState(() => _cars.removeAt(e.key)),
                                onTap: () => context.pushNamed('car-detail', pathParameters: {'id': e.value.id}),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    if (showCars && showDrivers && _drivers.isNotEmpty) SizedBox(width: 24.r),
                    // Drivers column
                    if (showDrivers && _drivers.isNotEmpty)
                      SizedBox(
                        width: 300.r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28.r,
                                  height: 28.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.15 : 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(Iconsax.profile_2user_copy, color: const Color(0xFF00BCD4), size: 14.r),
                                ),
                                SizedBox(width: 8.r),
                                Text(
                                  'favorites_filter_drivers'.tr(),
                                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.r),
                            ..._drivers.asMap().entries.map((e) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.r),
                                child: _FavDriverCard(
                                  driver: e.value,
                                  isDark: isDark,
                                  cs: cs,
                                  onRemove: () => setState(() => _drivers.removeAt(e.key)),
                                  onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': e.value.id}),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyFavorites extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const _EmptyFavorites({required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.heart, color: const Color(0xFFE91E63).withValues(alpha: 0.6), size: 40.r),
          ),
          SizedBox(height: 20.r),
          Text(
            'favorites_empty_title'.tr(),
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 8.r),
          SizedBox(
            width: 260.r,
            child: Text(
              'favorites_empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.5),
            ),
          ),
          SizedBox(height: 24.r),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 12.r),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.r),
                  ),
                ],
              ),
              child: Text(
                'favorites_explore'.tr(),
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FAV CAR CARD
// ============================================================

class _FavCarCard extends StatelessWidget {
  final _FavCar car;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const _FavCarCard({required this.car, required this.isDark, required this.cs, required this.onRemove, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                  blurRadius: 16.r,
                  offset: Offset(0, 4.r),
                ),
              ],
            ),
            child: SizedBox(
              height: 120.r,
              child: Row(
                children: [
                  // Image (left)
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(18.r), bottomLeft: Radius.circular(18.r)),
                    child: CachedNetworkImage(
                      imageUrl: car.imageUrl,
                      width: 120.r,
                      height: 120.r,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 120.r,
                        height: 120.r,
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                        child: Center(
                          child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.3), size: 28.r),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 120.r,
                        height: 120.r,
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                        child: Center(
                          child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.3), size: 28.r),
                        ),
                      ),
                    ),
                  ),
                  // Info (right)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(14.r, 10.r, 12.r, 10.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Name + heart
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  car.name,
                                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: onRemove,
                                child: Container(
                                  width: 30.r,
                                  height: 30.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.15 : 0.08),
                                    borderRadius: BorderRadius.circular(9.r),
                                  ),
                                  child: Icon(Iconsax.heart_copy, color: const Color(0xFFE91E63), size: 14.r),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.r),
                          // Brand + Rating
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 3.r),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  car.brand,
                                  style: TextStyle(fontSize: 10.r, color: cs.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(width: 8.r),
                              Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 12.r),
                              SizedBox(width: 3.r),
                              Text(
                                car.rating.toString(),
                                style: TextStyle(
                                  fontSize: 11.r,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.r),
                          // Price + Book
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  OmrIcon(size: 13.r, color: cs.primary),
                                  SizedBox(width: 3.r),
                                  Text(
                                    '${car.pricePerDay.toInt()}/${'day'.tr()}',
                                    style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.primary),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 7.r),
                                  decoration: BoxDecoration(
                                    gradient: primaryGradient,
                                    borderRadius: BorderRadius.circular(9.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0C2485).withValues(alpha: 0.25),
                                        blurRadius: 8.r,
                                        offset: Offset(0, 3.r),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'book_now'.tr(),
                                    style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}

// ============================================================
// FAV DRIVER CARD
// ============================================================

class _FavDriverCard extends StatelessWidget {
  final _FavDriver driver;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const _FavDriverCard({
    required this.driver,
    required this.isDark,
    required this.cs,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 14.r,
                  offset: Offset(0, 4.r),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CachedNetworkImage(
                      imageUrl: driver.avatarUrl,
                      imageBuilder: (_, img) => CircleAvatar(radius: 24.r, backgroundImage: img),
                      placeholder: (_, __) => CircleAvatar(
                        radius: 24.r,
                        backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                        child: Icon(Iconsax.user_copy, size: 20.r, color: cs.primary.withValues(alpha: 0.5)),
                      ),
                      errorWidget: (_, __, ___) => CircleAvatar(
                        radius: 24.r,
                        backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                        child: Icon(Iconsax.user_copy, size: 20.r, color: cs.primary.withValues(alpha: 0.5)),
                      ),
                    ),
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
                SizedBox(width: 12.r),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.r),
                      Row(
                        children: [
                          Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 12.r),
                          SizedBox(width: 3.r),
                          Text(
                            '${driver.rating}  ·  ${driver.trips} trips',
                            style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                          ),
                          SizedBox(width: 8.r),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.15 : 0.1),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              driver.speciality,
                              style: TextStyle(
                                fontSize: 9.r,
                                color: const Color(0xFF00BCD4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Remove button
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Iconsax.heart_copy, color: const Color(0xFFE91E63), size: 15.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
