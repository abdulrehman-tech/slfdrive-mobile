import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../../widgets/omr_icon.dart';
import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';

// ============================================================
// MOCK DATA
// ============================================================

class _DriverItem {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int trips;
  final String speciality;
  final double pricePerDay;
  final List<String> languages;
  final int yearsExperience;
  final bool isAvailable;

  const _DriverItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.trips,
    required this.speciality,
    required this.pricePerDay,
    required this.languages,
    required this.yearsExperience,
    this.isAvailable = true,
  });
}

const _mockDrivers = [
  _DriverItem(
    id: '1',
    name: 'Rashid Al-Suleimani',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    rating: 4.9,
    trips: 312,
    speciality: 'Chauffeur',
    pricePerDay: 80,
    languages: ['English', 'Arabic'],
    yearsExperience: 8,
  ),
  _DriverItem(
    id: '2',
    name: 'Mohammed Khalid',
    avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    rating: 4.8,
    trips: 198,
    speciality: 'Airport',
    pricePerDay: 65,
    languages: ['English', 'Arabic', 'Urdu'],
    yearsExperience: 5,
  ),
  _DriverItem(
    id: '3',
    name: 'Yusuf Hassan',
    avatarUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
    rating: 4.7,
    trips: 156,
    speciality: 'Daily',
    pricePerDay: 55,
    languages: ['English', 'Arabic'],
    yearsExperience: 3,
  ),
  _DriverItem(
    id: '4',
    name: 'Ahmed Al-Balushi',
    avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
    rating: 4.9,
    trips: 421,
    speciality: 'Chauffeur',
    pricePerDay: 95,
    languages: ['English', 'Arabic', 'Hindi'],
    yearsExperience: 10,
  ),
  _DriverItem(
    id: '5',
    name: 'Salim Al-Rawahi',
    avatarUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
    rating: 4.6,
    trips: 87,
    speciality: 'Airport',
    pricePerDay: 60,
    languages: ['English', 'Arabic'],
    yearsExperience: 2,
    isAvailable: false,
  ),
  _DriverItem(
    id: '6',
    name: 'Omar Al-Habsi',
    avatarUrl: 'https://randomuser.me/api/portraits/men/78.jpg',
    rating: 4.8,
    trips: 234,
    speciality: 'Daily',
    pricePerDay: 50,
    languages: ['English', 'Arabic'],
    yearsExperience: 6,
  ),
];

const _specialities = ['All', 'Chauffeur', 'Airport', 'Daily'];

// ============================================================
// DRIVER LISTING SCREEN
// ============================================================

class DriverListingScreen extends StatefulWidget {
  final String? initialFilter;
  const DriverListingScreen({super.key, this.initialFilter});

  @override
  State<DriverListingScreen> createState() => _DriverListingScreenState();
}

class _DriverListingScreenState extends State<DriverListingScreen> {
  late String _selectedSpeciality;
  String _sortBy = 'popular';

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  void initState() {
    super.initState();
    _selectedSpeciality = widget.initialFilter ?? 'All';
  }

  List<_DriverItem> get _filteredDrivers {
    var drivers = _selectedSpeciality == 'All'
        ? _mockDrivers
        : _mockDrivers.where((d) => d.speciality == _selectedSpeciality).toList();
    switch (_sortBy) {
      case 'price_low':
        drivers = List.from(drivers)..sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'price_high':
        drivers = List.from(drivers)..sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'rating':
        drivers = List.from(drivers)..sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'experience':
        drivers = List.from(drivers)..sort((a, b) => b.yearsExperience.compareTo(a.yearsExperience));
        break;
    }
    return drivers;
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
  // MOBILE LAYOUT
  // ==========================================================================

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final drivers = _filteredDrivers;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App bar
        SliverAppBar(
          pinned: true,
          floating: false,
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
          title: Text(
            'driver_listing_title'.tr(),
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 16.r),
              child: GestureDetector(
                onTap: () => _showSortSheet(isDark, cs),
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
                  child: Icon(Iconsax.sort, color: cs.onSurface.withValues(alpha: 0.6), size: 18.r),
                ),
              ),
            ),
          ],
        ),
        // Speciality filter chips
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(top: 12.r),
            child: SizedBox(
              height: 44.r,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                itemCount: _specialities.length,
                itemBuilder: (_, i) {
                  final active = _selectedSpeciality == _specialities[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.r),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSpeciality = _specialities[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                        decoration: BoxDecoration(
                          color: active
                              ? cs.primary.withValues(alpha: isDark ? 0.2 : 0.12)
                              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(12.r),
                          border: active ? Border.all(color: cs.primary.withValues(alpha: 0.3)) : null,
                        ),
                        child: Center(
                          child: Text(
                            _specialities[i],
                            style: TextStyle(
                              fontSize: 12.r,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.r)),
        // Results count
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Text(
              '${drivers.length} ${'driver_listing_results'.tr()}',
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.r)),
        // Driver cards
        if (drivers.isEmpty)
          SliverFillRemaining(child: _buildEmptyState(isDark, cs))
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.only(bottom: 12.r),
                  child: _DriverListCard(
                    driver: drivers[i],
                    isDark: isDark,
                    cs: cs,
                    onTap: () => _navigateToDetail(drivers[i]),
                  ),
                ),
                childCount: drivers.length,
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 40.r)),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT
  // ==========================================================================

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final drivers = _filteredDrivers;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + back + sort
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                  SizedBox(width: 12.r),
                  Text(
                    'driver_listing_title'.tr(),
                    style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showSortSheet(isDark, cs),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.sort, size: 16.r, color: cs.onSurface.withValues(alpha: 0.6)),
                          SizedBox(width: 6.r),
                          Text(
                            'common_sort'.tr(),
                            style: TextStyle(
                              fontSize: 12.r,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.r),
              // Speciality chips
              Wrap(
                spacing: 8.r,
                runSpacing: 8.r,
                children: _specialities.map((s) {
                  final active = _selectedSpeciality == s;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSpeciality = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                      decoration: BoxDecoration(
                        color: active
                            ? cs.primary.withValues(alpha: isDark ? 0.2 : 0.12)
                            : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(12.r),
                        border: active ? Border.all(color: cs.primary.withValues(alpha: 0.3)) : null,
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12.r,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.r),
              Text(
                '${drivers.length} ${'driver_listing_results'.tr()}',
                style: TextStyle(
                  fontSize: 12.r,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.r),
              if (drivers.isEmpty)
                SizedBox(height: 300.r, child: _buildEmptyState(isDark, cs))
              else
                Wrap(
                  spacing: 16.r,
                  runSpacing: 16.r,
                  children: drivers
                      .map(
                        (d) => SizedBox(
                          width: 340.r,
                          child: _DriverListCard(driver: d, isDark: isDark, cs: cs, onTap: () => _navigateToDetail(d)),
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.profile_2user, color: cs.primary.withValues(alpha: 0.5), size: 36.r),
          ),
          SizedBox(height: 16.r),
          Text(
            'driver_listing_empty'.tr(),
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 6.r),
          Text(
            'driver_listing_empty_subtitle'.tr(),
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(bool isDark, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortBottomSheet(
        isDark: isDark,
        cs: cs,
        current: _sortBy,
        onSelect: (v) {
          setState(() => _sortBy = v);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToDetail(_DriverItem driver) {
    context.pushNamed('driver-detail', pathParameters: {'id': driver.id});
  }
}

// ============================================================
// DRIVER LIST CARD
// ============================================================

class _DriverListCard extends StatelessWidget {
  final _DriverItem driver;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _DriverListCard({required this.driver, required this.isDark, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(14.r),
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
            child: Row(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CachedNetworkImage(
                      imageUrl: driver.avatarUrl,
                      imageBuilder: (_, img) => Container(
                        width: 56.r,
                        height: 56.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          image: DecorationImage(image: img, fit: BoxFit.cover),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                            width: 2,
                          ),
                        ),
                      ),
                      placeholder: (_, __) => Container(
                        width: 56.r,
                        height: 56.r,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(Iconsax.user_copy, size: 22.r, color: cs.primary.withValues(alpha: 0.4)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 56.r,
                        height: 56.r,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(Iconsax.user_copy, size: 22.r, color: cs.primary.withValues(alpha: 0.4)),
                      ),
                    ),
                    if (driver.isAvailable)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14.r,
                          height: 14.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? const Color(0xFF1A1A2A) : Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 14.r),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + availability
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              driver.name,
                              style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!driver.isAvailable)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                'driver_status_busy'.tr(),
                                style: TextStyle(
                                  fontSize: 9.r,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE53935),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.r),
                      // Stats row
                      Row(
                        children: [
                          Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 12.r),
                          SizedBox(width: 3.r),
                          Text(
                            '${driver.rating}',
                            style: TextStyle(
                              fontSize: 11.r,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(width: 8.r),
                          Icon(Iconsax.car, size: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
                          SizedBox(width: 3.r),
                          Text(
                            '${driver.trips} trips',
                            style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
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
                      SizedBox(height: 8.r),
                      // Languages + Experience + Price
                      Row(
                        children: [
                          Icon(Iconsax.language_circle, size: 11.r, color: cs.onSurface.withValues(alpha: 0.35)),
                          SizedBox(width: 3.r),
                          Expanded(
                            child: Text(
                              driver.languages.join(', '),
                              style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.45)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              OmrIcon(size: 12.r, color: cs.primary),
                              SizedBox(width: 3.r),
                              Text(
                                '${driver.pricePerDay.toInt()}${'driver_detail_per_day'.tr()}',
                                style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold, color: cs.primary),
                              ),
                            ],
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
    );
  }
}

// ============================================================
// SORT BOTTOM SHEET
// ============================================================

class _SortBottomSheet extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final String current;
  final ValueChanged<String> onSelect;

  const _SortBottomSheet({required this.isDark, required this.cs, required this.current, required this.onSelect});

  static final _options = [
    ('popular', Iconsax.star_1, 'Most Popular'),
    ('price_low', CupertinoIcons.arrow_down, 'Price: Low to High'),
    ('price_high', CupertinoIcons.arrow_up, 'Price: High to Low'),
    ('rating', Iconsax.like_1, 'Highest Rated'),
    ('experience', Iconsax.medal_star, 'Most Experienced'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 20.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.r),
                Text(
                  'driver_listing_sort'.tr(),
                  style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                SizedBox(height: 16.r),
                ...List.generate(_options.length, (i) {
                  final o = _options[i];
                  final active = current == o.$1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 6.r),
                    child: GestureDetector(
                      onTap: () => onSelect(o.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 13.r),
                        decoration: BoxDecoration(
                          color: active ? cs.primary.withValues(alpha: isDark ? 0.15 : 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                          border: active
                              ? Border.all(color: cs.primary.withValues(alpha: 0.3))
                              : Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                        ),
                        child: Row(
                          children: [
                            Icon(o.$2, size: 18.r, color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.5)),
                            SizedBox(width: 12.r),
                            Expanded(
                              child: Text(
                                o.$3,
                                style: TextStyle(
                                  fontSize: 13.r,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                  color: active ? cs.primary : cs.onSurface,
                                ),
                              ),
                            ),
                            if (active)
                              Container(
                                width: 20.r,
                                height: 20.r,
                                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                                child: Icon(Icons.check_rounded, size: 13.r, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
