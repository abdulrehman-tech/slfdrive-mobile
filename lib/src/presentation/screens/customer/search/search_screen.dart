import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

class _SearchResultCar {
  final String id;
  final String name;
  final String imageUrl;
  final double pricePerDay;
  final String brand;
  final double rating;
  final String transmission;
  final int seats;
  final String fuelType;
  const _SearchResultCar({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerDay,
    required this.brand,
    required this.rating,
    required this.transmission,
    required this.seats,
    required this.fuelType,
  });
}

class _SearchResultDriver {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int trips;
  final String speciality;
  final double pricePerDay;
  const _SearchResultDriver({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.trips,
    required this.speciality,
    required this.pricePerDay,
  });
}

const _allCars = [
  _SearchResultCar(
    id: '1',
    name: 'Mercedes AMG GT',
    imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    pricePerDay: 250,
    brand: 'Mercedes',
    rating: 4.9,
    transmission: 'Automatic',
    seats: 2,
    fuelType: 'Petrol',
  ),
  _SearchResultCar(
    id: '2',
    name: 'BMW M4 Competition',
    imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
    pricePerDay: 190,
    brand: 'BMW',
    rating: 4.8,
    transmission: 'Automatic',
    seats: 4,
    fuelType: 'Petrol',
  ),
  _SearchResultCar(
    id: '3',
    name: 'Porsche 911 Turbo S',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    pricePerDay: 320,
    brand: 'Porsche',
    rating: 4.9,
    transmission: 'PDK',
    seats: 4,
    fuelType: 'Petrol',
  ),
  _SearchResultCar(
    id: '4',
    name: 'Toyota Land Cruiser',
    imageUrl: 'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=800&q=80',
    pricePerDay: 120,
    brand: 'Toyota',
    rating: 4.7,
    transmission: 'Automatic',
    seats: 7,
    fuelType: 'Diesel',
  ),
  _SearchResultCar(
    id: '5',
    name: 'Audi RS7',
    imageUrl: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',
    pricePerDay: 280,
    brand: 'Audi',
    rating: 4.8,
    transmission: 'Automatic',
    seats: 4,
    fuelType: 'Petrol',
  ),
];

const _allDrivers = [
  _SearchResultDriver(
    id: '1',
    name: 'Ahmed Al-Farsi',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    rating: 4.9,
    trips: 312,
    speciality: 'Chauffeur',
    pricePerDay: 80,
  ),
  _SearchResultDriver(
    id: '2',
    name: 'Mohammed K.',
    avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    rating: 4.8,
    trips: 198,
    speciality: 'Airport',
    pricePerDay: 60,
  ),
  _SearchResultDriver(
    id: '3',
    name: 'Yusuf Hassan',
    avatarUrl: 'https://randomuser.me/api/portraits/men/61.jpg',
    rating: 4.7,
    trips: 421,
    speciality: 'City Tours',
    pricePerDay: 70,
  ),
];

// ============================================================
// SEARCH SCREEN
// ============================================================

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  // Filter state
  int _typeFilter = 0; // 0=All, 1=Cars, 2=Drivers
  int _durationFilter = 0; // 0=Daily, 1=Weekly, 2=Monthly, 3=Yearly
  RangeValues _priceRange = const RangeValues(0, 500);
  final Set<String> _selectedBrands = {};
  double _minRating = 0;

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<_SearchResultCar> get _filteredCars {
    if (_typeFilter == 2) return [];
    return _allCars.where((c) {
      if (_query.isNotEmpty &&
          !c.name.toLowerCase().contains(_query.toLowerCase()) &&
          !c.brand.toLowerCase().contains(_query.toLowerCase()))
        return false;
      if (_selectedBrands.isNotEmpty && !_selectedBrands.contains(c.brand)) return false;
      if (c.pricePerDay < _priceRange.start || c.pricePerDay > _priceRange.end) return false;
      if (c.rating < _minRating) return false;
      return true;
    }).toList();
  }

  List<_SearchResultDriver> get _filteredDrivers {
    if (_typeFilter == 1) return [];
    return _allDrivers.where((d) {
      if (_query.isNotEmpty &&
          !d.name.toLowerCase().contains(_query.toLowerCase()) &&
          !d.speciality.toLowerCase().contains(_query.toLowerCase()))
        return false;
      if (d.pricePerDay < _priceRange.start || d.pricePerDay > _priceRange.end) return false;
      if (d.rating < _minRating) return false;
      return true;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _typeFilter != 0 ||
      _durationFilter != 0 ||
      _priceRange != const RangeValues(0, 500) ||
      _selectedBrands.isNotEmpty ||
      _minRating > 0;

  int get _activeFilterCount {
    int count = 0;
    if (_typeFilter != 0) count++;
    if (_durationFilter != 0) count++;
    if (_priceRange != const RangeValues(0, 500)) count++;
    if (_selectedBrands.isNotEmpty) count++;
    if (_minRating > 0) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.desktop;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A0A14), const Color(0xFF12122A)]
                : [const Color(0xFFF5F7FA), const Color(0xFFE8EDF5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: isDesktop ? _buildDesktopLayout(isDark, cs) : _buildMobileLayout(isDark, cs)),
      ),
    );
  }

  // ==========================================================================
  // MOBILE LAYOUT
  // ==========================================================================

  Widget _buildMobileLayout(bool isDark, ColorScheme cs) {
    final cars = _filteredCars;
    final drivers = _filteredDrivers;
    final hasResults = cars.isNotEmpty || drivers.isNotEmpty;

    return Column(
      children: [
        // Search bar
        _buildSearchAppBar(isDark, cs),
        // Results
        Expanded(
          child: !hasResults
              ? _buildEmptyResults(isDark, cs)
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 0),
                      sliver: SliverToBoxAdapter(child: _buildResultsHeader(isDark, cs, cars.length + drivers.length)),
                    ),
                    if (cars.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: EdgeInsets.only(bottom: 12.r),
                              child: _SearchCarCard(
                                car: cars[i],
                                isDark: isDark,
                                cs: cs,
                                onTap: () => context.pushNamed('car-detail', pathParameters: {'id': cars[i].id}),
                              ),
                            ),
                            childCount: cars.length,
                          ),
                        ),
                      ),
                    if (drivers.isNotEmpty && cars.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 12.r),
                          child: _buildSectionLabel(
                            isDark,
                            cs,
                            'search_drivers_section'.tr(),
                            Iconsax.profile_2user_copy,
                            const Color(0xFF00BCD4),
                          ),
                        ),
                      ),
                    if (drivers.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: EdgeInsets.only(bottom: 12.r),
                              child: _SearchDriverCard(
                                driver: drivers[i],
                                isDark: isDark,
                                cs: cs,
                                onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': drivers[i].id}),
                              ),
                            ),
                            childCount: drivers.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: SizedBox(height: 40.r)),
                  ],
                ),
        ),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT
  // ==========================================================================

  Widget _buildDesktopLayout(bool isDark, ColorScheme cs) {
    final cars = _filteredCars;
    final drivers = _filteredDrivers;
    final hasResults = cars.isNotEmpty || drivers.isNotEmpty;

    return Column(
      children: [
        _buildSearchAppBar(isDark, cs),
        Expanded(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1100.r),
              padding: EdgeInsets.symmetric(horizontal: 24.r),
              child: _query.isEmpty && !_hasActiveFilters
                  ? _buildInitialState(isDark, cs)
                  : !hasResults
                  ? _buildEmptyResults(isDark, cs)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cars column
                        if (_typeFilter != 2)
                          Expanded(
                            flex: 3,
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(top: 16.r, bottom: 40.r),
                              children: [
                                _buildResultsHeader(isDark, cs, cars.length + drivers.length),
                                SizedBox(height: 12.r),
                                Wrap(
                                  spacing: 16.r,
                                  runSpacing: 16.r,
                                  children: cars
                                      .map(
                                        (c) => SizedBox(
                                          width: 340.r,
                                          child: _SearchCarCard(
                                            car: c,
                                            isDark: isDark,
                                            cs: cs,
                                            onTap: () => context.pushNamed('car-detail', pathParameters: {'id': c.id}),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        if (_typeFilter == 0 && cars.isNotEmpty && drivers.isNotEmpty) SizedBox(width: 24.r),
                        // Drivers column
                        if (_typeFilter != 1 && drivers.isNotEmpty)
                          SizedBox(
                            width: 300.r,
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(top: 16.r, bottom: 40.r),
                              children: [
                                _buildSectionLabel(
                                  isDark,
                                  cs,
                                  'search_drivers_section'.tr(),
                                  Iconsax.profile_2user_copy,
                                  const Color(0xFF00BCD4),
                                ),
                                SizedBox(height: 12.r),
                                ...drivers.map(
                                  (d) => Padding(
                                    padding: EdgeInsets.only(bottom: 12.r),
                                    child: _SearchDriverCard(
                                      driver: d,
                                      isDark: isDark,
                                      cs: cs,
                                      onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': d.id}),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SEARCH APP BAR
  // ==========================================================================

  Widget _buildSearchAppBar(bool isDark, ColorScheme cs) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 12.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E0E1C).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.88),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(CupertinoIcons.back, size: 18.r, color: cs.onSurface),
                ),
              ),
              SizedBox(width: 10.r),
              // Search field
              Expanded(
                child: Container(
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 12.r),
                      Icon(Iconsax.search_normal_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      SizedBox(width: 8.r),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: 'search_hint'.tr(),
                            hintStyle: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.35)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12.r),
                            isCollapsed: true,
                          ),
                          style: TextStyle(fontSize: 14.r, color: cs.onSurface),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Icon(Iconsax.close_circle, size: 18.r, color: cs.onSurface.withValues(alpha: 0.4)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.r),
              // Filter button
              GestureDetector(
                onTap: () => _showFilterSheet(isDark, cs),
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    gradient: _hasActiveFilters
                        ? const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF677EF0)])
                        : null,
                    color: _hasActiveFilters
                        ? null
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Iconsax.setting_4,
                        size: 20.r,
                        color: _hasActiveFilters ? Colors.white : cs.onSurface.withValues(alpha: 0.6),
                      ),
                      if (_activeFilterCount > 0)
                        Positioned(
                          top: 6.r,
                          right: 6.r,
                          child: Container(
                            width: 14.r,
                            height: 14.r,
                            decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '$_activeFilterCount',
                                style: TextStyle(fontSize: 8.r, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // INITIAL STATE (no query)
  // ==========================================================================

  Widget _buildInitialState(bool isDark, ColorScheme cs) {
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
            child: Icon(Iconsax.search_normal_copy, color: cs.primary.withValues(alpha: 0.5), size: 36.r),
          ),
          SizedBox(height: 16.r),
          Text(
            'search_initial_title'.tr(),
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 6.r),
          Text(
            'search_initial_subtitle'.tr(),
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EMPTY RESULTS
  // ==========================================================================

  Widget _buildEmptyResults(bool isDark, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.search_zoom_out, color: const Color(0xFFE91E63).withValues(alpha: 0.5), size: 36.r),
          ),
          SizedBox(height: 16.r),
          Text(
            'search_no_results'.tr(),
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 6.r),
          Text(
            'search_no_results_subtitle'.tr(),
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.r),
          if (_hasActiveFilters)
            GestureDetector(
              onTap: _resetFilters,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 10.r),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'search_clear_filters'.tr(),
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RESULTS HEADER
  // ==========================================================================

  Widget _buildResultsHeader(bool isDark, ColorScheme cs, int count) {
    return Row(
      children: [
        Text(
          '$count ${'search_results'.tr()}',
          style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        const Spacer(),
        if (_hasActiveFilters)
          GestureDetector(
            onTap: _resetFilters,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.close_circle, size: 14.r, color: const Color(0xFFE91E63)),
                SizedBox(width: 4.r),
                Text(
                  'search_clear_filters'.tr(),
                  style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w600, color: const Color(0xFFE91E63)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionLabel(bool isDark, ColorScheme cs, String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 26.r,
          height: 26.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Icon(icon, color: color, size: 13.r),
        ),
        SizedBox(width: 8.r),
        Text(
          title,
          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ],
    );
  }

  // ==========================================================================
  // FILTER BOTTOM SHEET
  // ==========================================================================

  void _showFilterSheet(bool isDark, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterBottomSheet(
        isDark: isDark,
        cs: cs,
        typeFilter: _typeFilter,
        durationFilter: _durationFilter,
        priceRange: _priceRange,
        selectedBrands: Set.from(_selectedBrands),
        minRating: _minRating,
        onApply: (type, duration, price, brands, rating) {
          setState(() {
            _typeFilter = type;
            _durationFilter = duration;
            _priceRange = price;
            _selectedBrands
              ..clear()
              ..addAll(brands);
            _minRating = rating;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _typeFilter = 0;
      _durationFilter = 0;
      _priceRange = const RangeValues(0, 500);
      _selectedBrands.clear();
      _minRating = 0;
    });
  }
}

// ============================================================
// FILTER BOTTOM SHEET
// ============================================================

class _FilterBottomSheet extends StatefulWidget {
  final bool isDark;
  final ColorScheme cs;
  final int typeFilter;
  final int durationFilter;
  final RangeValues priceRange;
  final Set<String> selectedBrands;
  final double minRating;
  final void Function(int type, int duration, RangeValues price, Set<String> brands, double rating) onApply;

  const _FilterBottomSheet({
    required this.isDark,
    required this.cs,
    required this.typeFilter,
    required this.durationFilter,
    required this.priceRange,
    required this.selectedBrands,
    required this.minRating,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late int _type;
  late int _duration;
  late RangeValues _price;
  late Set<String> _brands;
  late double _rating;

  static const _brandsList = ['Toyota', 'Mercedes', 'BMW', 'Porsche', 'Audi', 'Ferrari', 'Lamborghini'];
  static const _typeLabels = ['search_filter_all', 'search_filter_cars', 'search_filter_drivers'];
  static const _typeIcons = [Iconsax.search_normal_copy, Iconsax.car_copy, Iconsax.profile_2user_copy];
  static const _durationLabels = [
    'search_filter_daily',
    'search_filter_weekly',
    'search_filter_monthly',
    'search_filter_yearly',
  ];
  static const _durationIcons = [Iconsax.calendar_1, Iconsax.calendar, Iconsax.calendar_tick, Iconsax.calendar_2];

  @override
  void initState() {
    super.initState();
    _type = widget.typeFilter;
    _duration = widget.durationFilter;
    _price = widget.priceRange;
    _brands = Set.from(widget.selectedBrands);
    _rating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cs = widget.cs;

    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14142A).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: EdgeInsets.only(top: 12.r),
                child: Container(
                  width: 36.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 4.r),
                child: Row(
                  children: [
                    Icon(Iconsax.setting_4, size: 20.r, color: cs.primary),
                    SizedBox(width: 8.r),
                    Text(
                      'search_filters'.tr(),
                      style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _type = 0;
                          _duration = 0;
                          _price = const RangeValues(0, 500);
                          _brands.clear();
                          _rating = 0;
                        });
                      },
                      child: Text(
                        'search_reset'.tr(),
                        style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: const Color(0xFFE91E63)),
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TYPE
                      _sectionTitle('search_filter_type'.tr(), cs),
                      SizedBox(height: 10.r),
                      Wrap(
                        spacing: 8.r,
                        runSpacing: 8.r,
                        children: List.generate(_typeLabels.length, (i) {
                          final active = _type == i;
                          return GestureDetector(
                            onTap: () => setState(() => _type = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 9.r),
                              decoration: BoxDecoration(
                                gradient: active
                                    ? const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF3D5AFE)])
                                    : null,
                                color: active
                                    ? null
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(alpha: 0.04)),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: active
                                      ? Colors.transparent
                                      : (isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.06)),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _typeIcons[i],
                                    size: 14.r,
                                    color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                  SizedBox(width: 6.r),
                                  Text(
                                    _typeLabels[i].tr(),
                                    style: TextStyle(
                                      fontSize: 12.r,
                                      fontWeight: FontWeight.w600,
                                      color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 20.r),

                      // DURATION
                      _sectionTitle('search_filter_duration'.tr(), cs),
                      SizedBox(height: 10.r),
                      Wrap(
                        spacing: 8.r,
                        runSpacing: 8.r,
                        children: List.generate(_durationLabels.length, (i) {
                          final active = _duration == i;
                          return GestureDetector(
                            onTap: () => setState(() => _duration = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 9.r),
                              decoration: BoxDecoration(
                                gradient: active
                                    ? const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF3D5AFE)])
                                    : null,
                                color: active
                                    ? null
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(alpha: 0.04)),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: active
                                      ? Colors.transparent
                                      : (isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.06)),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _durationIcons[i],
                                    size: 14.r,
                                    color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                  SizedBox(width: 6.r),
                                  Text(
                                    _durationLabels[i].tr(),
                                    style: TextStyle(
                                      fontSize: 12.r,
                                      fontWeight: FontWeight.w600,
                                      color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 20.r),

                      // PRICE RANGE
                      _sectionTitle('search_filter_price'.tr(), cs),
                      SizedBox(height: 6.r),
                      Row(
                        children: [
                          OmrIcon(size: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                          SizedBox(width: 3.r),
                          Text(
                            '${_price.start.toInt()}',
                            style: TextStyle(
                              fontSize: 12.r,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          OmrIcon(size: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                          SizedBox(width: 3.r),
                          Text(
                            '${_price.end.toInt()}',
                            style: TextStyle(
                              fontSize: 12.r,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: cs.primary,
                          inactiveTrackColor: cs.onSurface.withValues(alpha: 0.1),
                          thumbColor: cs.primary,
                          overlayColor: cs.primary.withValues(alpha: 0.1),
                          trackHeight: 3.r,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
                        ),
                        child: RangeSlider(
                          values: _price,
                          min: 0,
                          max: 500,
                          divisions: 50,
                          onChanged: (v) => setState(() => _price = v),
                        ),
                      ),
                      SizedBox(height: 12.r),

                      // BRANDS
                      if (_type != 2) ...[
                        _sectionTitle('search_filter_brands'.tr(), cs),
                        SizedBox(height: 10.r),
                        Wrap(
                          spacing: 8.r,
                          runSpacing: 8.r,
                          children: _brandsList.map((b) {
                            final active = _brands.contains(b);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (active) {
                                  _brands.remove(b);
                                } else {
                                  _brands.add(b);
                                }
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
                                decoration: BoxDecoration(
                                  gradient: active
                                      ? const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF3D5AFE)])
                                      : null,
                                  color: active
                                      ? null
                                      : (isDark
                                            ? Colors.white.withValues(alpha: 0.06)
                                            : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: active
                                        ? Colors.transparent
                                        : (isDark
                                              ? Colors.white.withValues(alpha: 0.08)
                                              : Colors.black.withValues(alpha: 0.06)),
                                  ),
                                ),
                                child: Text(
                                  b,
                                  style: TextStyle(
                                    fontSize: 12.r,
                                    fontWeight: FontWeight.w600,
                                    color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.r),
                      ],

                      // RATING
                      _sectionTitle('search_filter_rating'.tr(), cs),
                      SizedBox(height: 10.r),
                      Row(
                        children: List.generate(5, (i) {
                          final starVal = (i + 1).toDouble();
                          final active = _rating >= starVal;
                          return GestureDetector(
                            onTap: () => setState(() => _rating = _rating == starVal ? 0 : starVal),
                            child: Padding(
                              padding: EdgeInsets.only(right: 8.r),
                              child: Icon(
                                active ? Iconsax.star_1_copy : Iconsax.star_1,
                                size: 28.r,
                                color: active ? const Color(0xFFFFC107) : cs.onSurface.withValues(alpha: 0.2),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 4.r),
                      if (_rating > 0)
                        Text(
                          '${'search_filter_min_rating'.tr()} ${_rating.toInt()}+',
                          style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.45)),
                        ),
                    ],
                  ),
                ),
              ),
              // Apply button
              Padding(
                padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 16.r),
                child: GestureDetector(
                  onTap: () => widget.onApply(_type, _duration, _price, _brands, _rating),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF3D5AFE)]),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C2485).withValues(alpha: 0.3),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.r),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'search_apply_filters'.tr(),
                        style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.7)),
    );
  }
}

// ============================================================
// SEARCH CAR CARD
// ============================================================

class _SearchCarCard extends StatelessWidget {
  final _SearchResultCar car;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _SearchCarCard({required this.car, required this.isDark, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: SizedBox(
              height: 120.r,
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), bottomLeft: Radius.circular(16.r)),
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
                  // Info
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.r, 10.r, 12.r, 10.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            car.name,
                            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.r),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Text(
                                  car.brand,
                                  style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(width: 6.r),
                              Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 11.r),
                              SizedBox(width: 2.r),
                              Text(
                                car.rating.toString(),
                                style: TextStyle(
                                  fontSize: 10.r,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.r),
                          Row(
                            children: [
                              _specChip(Iconsax.people_copy, '${car.seats}', cs),
                              SizedBox(width: 6.r),
                              _specChip(Iconsax.cpu_setting, car.transmission, cs),
                            ],
                          ),
                          SizedBox(height: 6.r),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OmrIcon(size: 12.r, color: cs.primary),
                              SizedBox(width: 3.r),
                              Text(
                                '${car.pricePerDay.toInt()}/${'day'.tr()}',
                                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.primary),
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

  Widget _specChip(IconData icon, String label, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: cs.onSurface.withValues(alpha: 0.4)),
          SizedBox(width: 3.r),
          Text(
            label,
            style: TextStyle(fontSize: 9.r, color: cs.onSurface.withValues(alpha: 0.55), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SEARCH DRIVER CARD
// ============================================================

class _SearchDriverCard extends StatelessWidget {
  final _SearchResultDriver driver;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _SearchDriverCard({required this.driver, required this.isDark, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
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
                        backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                      ),
                      errorWidget: (_, __, ___) => CircleAvatar(
                        radius: 24.r,
                        backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
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
                SizedBox(width: 10.r),
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
                      SizedBox(height: 3.r),
                      Row(
                        children: [
                          Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 11.r),
                          SizedBox(width: 2.r),
                          Text(
                            '${driver.rating}',
                            style: TextStyle(
                              fontSize: 10.r,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(width: 6.r),
                          Text(
                            '·',
                            style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.3)),
                          ),
                          SizedBox(width: 6.r),
                          Text(
                            '${driver.trips} trips',
                            style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price + speciality
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        driver.speciality,
                        style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 6.r),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OmrIcon(size: 10.r, color: cs.primary),
                        SizedBox(width: 2.r),
                        Text(
                          '${driver.pricePerDay.toInt()}/${'day'.tr()}',
                          style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.bold, color: cs.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
