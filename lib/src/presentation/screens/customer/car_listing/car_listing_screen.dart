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

class _CarItem {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double pricePerDay;
  final double rating;
  final int seats;
  final String transmission;
  final String fuelType;
  final bool isAvailable;

  const _CarItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.pricePerDay,
    required this.rating,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    this.isAvailable = true,
  });
}

const _mockCars = [
  _CarItem(
    id: '1',
    name: 'Mercedes AMG GT',
    brand: 'Mercedes',
    imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    pricePerDay: 250,
    rating: 4.9,
    seats: 2,
    transmission: 'Auto',
    fuelType: 'Petrol',
  ),
  _CarItem(
    id: '2',
    name: 'BMW M4 Competition',
    brand: 'BMW',
    imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
    pricePerDay: 190,
    rating: 4.8,
    seats: 4,
    transmission: 'Auto',
    fuelType: 'Petrol',
  ),
  _CarItem(
    id: '3',
    name: 'Porsche 911 Turbo S',
    brand: 'Porsche',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    pricePerDay: 320,
    rating: 4.9,
    seats: 2,
    transmission: 'Auto',
    fuelType: 'Petrol',
  ),
  _CarItem(
    id: '4',
    name: 'Audi RS7 Sportback',
    brand: 'Audi',
    imageUrl: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',
    pricePerDay: 210,
    rating: 4.7,
    seats: 5,
    transmission: 'Auto',
    fuelType: 'Petrol',
  ),
  _CarItem(
    id: '5',
    name: 'Range Rover Sport',
    brand: 'Land Rover',
    imageUrl: 'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=800&q=80',
    pricePerDay: 280,
    rating: 4.8,
    seats: 5,
    transmission: 'Auto',
    fuelType: 'Diesel',
  ),
  _CarItem(
    id: '6',
    name: 'Tesla Model S',
    brand: 'Tesla',
    imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800&q=80',
    pricePerDay: 200,
    rating: 4.6,
    seats: 5,
    transmission: 'Auto',
    fuelType: 'Electric',
    isAvailable: false,
  ),
];

const _brands = ['All', 'Mercedes', 'BMW', 'Porsche', 'Audi', 'Land Rover', 'Tesla'];

// ============================================================
// CAR LISTING SCREEN
// ============================================================

class CarListingScreen extends StatefulWidget {
  final String? initialBrand;
  const CarListingScreen({super.key, this.initialBrand});

  @override
  State<CarListingScreen> createState() => _CarListingScreenState();
}

class _CarListingScreenState extends State<CarListingScreen> {
  late String _selectedBrand;
  String _sortBy = 'popular';

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialBrand ?? 'All';
  }

  List<_CarItem> get _filteredCars {
    var cars = _selectedBrand == 'All' ? _mockCars : _mockCars.where((c) => c.brand == _selectedBrand).toList();
    switch (_sortBy) {
      case 'price_low':
        cars = List.from(cars)..sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'price_high':
        cars = List.from(cars)..sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'rating':
        cars = List.from(cars)..sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return cars;
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
    final cars = _filteredCars;

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
            padding: EdgeInsets.only(left: 12.r),
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
                  child: Icon(Iconsax.arrow_left_2, color: cs.onSurface, size: 18.r),
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
            'car_listing_title'.tr(),
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.r),
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
        // Brand filter chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              itemCount: _brands.length,
              itemBuilder: (_, i) {
                final active = _selectedBrand == _brands[i];
                return Padding(
                  padding: EdgeInsets.only(right: 8.r),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBrand = _brands[i]),
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
                          _brands[i],
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
        SliverToBoxAdapter(child: SizedBox(height: 12.r)),
        // Results count
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Text(
              '${cars.length} ${'car_listing_results'.tr()}',
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.r)),
        // Car cards
        if (cars.isEmpty)
          SliverFillRemaining(child: _buildEmptyState(isDark, cs))
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.only(bottom: 14.r),
                  child: _CarListCard(car: cars[i], isDark: isDark, cs: cs, onTap: () => _navigateToDetail(cars[i])),
                ),
                childCount: cars.length,
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
    final cars = _filteredCars;

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
                      child: Icon(Iconsax.arrow_left_2, color: cs.onSurface, size: 18.r),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Text(
                    'car_listing_title'.tr(),
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
                            'Sort',
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
              // Brand chips
              Wrap(
                spacing: 8.r,
                runSpacing: 8.r,
                children: _brands.map((b) {
                  final active = _selectedBrand == b;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBrand = b),
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
                        b,
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
                '${cars.length} ${'car_listing_results'.tr()}',
                style: TextStyle(
                  fontSize: 12.r,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.r),
              if (cars.isEmpty)
                SizedBox(height: 300.r, child: _buildEmptyState(isDark, cs))
              else
                Wrap(
                  spacing: 16.r,
                  runSpacing: 16.r,
                  children: cars
                      .map(
                        (c) => SizedBox(
                          width: 340.r,
                          child: _CarListCard(car: c, isDark: isDark, cs: cs, onTap: () => _navigateToDetail(c)),
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
            child: Icon(Iconsax.car, color: cs.primary.withValues(alpha: 0.5), size: 36.r),
          ),
          SizedBox(height: 16.r),
          Text(
            'car_listing_empty'.tr(),
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 6.r),
          Text(
            'car_listing_empty_subtitle'.tr(),
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

  void _navigateToDetail(_CarItem car) {
    context.pushNamed('car-detail', pathParameters: {'id': car.id});
  }
}

// ============================================================
// CAR LIST CARD (horizontal)
// ============================================================

class _CarListCard extends StatelessWidget {
  final _CarItem car;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _CarListCard({required this.car, required this.isDark, required this.cs, required this.onTap});

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
              height: 140.r,
              child: Row(
                children: [
                  // Image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.r),
                          bottomLeft: Radius.circular(18.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: car.imageUrl,
                          width: 130.r,
                          height: 140.r,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 130.r,
                            height: 140.r,
                            color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                            child: Center(
                              child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.3), size: 28.r),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 130.r,
                            height: 140.r,
                            color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                            child: Center(
                              child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.3), size: 28.r),
                            ),
                          ),
                        ),
                      ),
                      if (!car.isAvailable)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18.r),
                              bottomLeft: Radius.circular(18.r),
                            ),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.5),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'Unavailable',
                                    style: TextStyle(fontSize: 9.r, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Info
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(14.r, 12.r, 12.r, 12.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Name
                          Text(
                            car.name,
                            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.r),
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
                                  style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w600),
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
                          SizedBox(height: 8.r),
                          // Specs row
                          Row(
                            children: [
                              _SpecChip(icon: Iconsax.people, label: '${car.seats}', isDark: isDark, cs: cs),
                              SizedBox(width: 6.r),
                              _SpecChip(icon: Iconsax.cpu_setting, label: car.transmission, isDark: isDark, cs: cs),
                              SizedBox(width: 6.r),
                              _SpecChip(icon: Iconsax.gas_station, label: car.fuelType, isDark: isDark, cs: cs),
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
                              if (car.isAvailable)
                                Container(
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
// SPEC CHIP
// ============================================================

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final ColorScheme cs;

  const _SpecChip({required this.icon, required this.label, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: cs.onSurface.withValues(alpha: 0.45)),
          SizedBox(width: 3.r),
          Text(
            label,
            style: TextStyle(fontSize: 9.r, color: cs.onSurface.withValues(alpha: 0.55), fontWeight: FontWeight.w500),
          ),
        ],
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

  static const _options = [
    ('popular', Iconsax.star_1, 'Most Popular'),
    ('price_low', Iconsax.arrow_down_2, 'Price: Low to High'),
    ('price_high', Iconsax.arrow_up_1, 'Price: High to Low'),
    ('rating', Iconsax.like_1, 'Highest Rated'),
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
                  'car_listing_sort'.tr(),
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
