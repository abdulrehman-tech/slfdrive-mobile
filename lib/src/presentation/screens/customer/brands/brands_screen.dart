import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';

// ============================================================
// MODEL + MOCK DATA
// ============================================================

class _Brand {
  final String name;
  final String logoAsset;
  final int carsCount;
  final String tagline;
  const _Brand(this.name, this.logoAsset, this.carsCount, this.tagline);
}

const _allBrands = <_Brand>[
  _Brand('Tesla', 'assets/images/brands/tesla.png', 12, 'Electric pioneers'),
  _Brand('Mercedes', 'assets/images/brands/mercedes-benz.png', 24, 'The best or nothing'),
  _Brand('BMW', 'assets/images/brands/bmw.png', 19, 'Sheer driving pleasure'),
  _Brand('Ferrari', 'assets/images/brands/ferrari.png', 6, 'Pure Italian passion'),
  _Brand('Toyota', 'assets/images/brands/toyota.png', 48, 'Reliable everyday'),
  _Brand('Audi', 'assets/images/brands/audi.png', 21, 'Vorsprung durch Technik'),
  _Brand('Porsche', 'assets/images/brands/porsche.png', 9, 'There is no substitute'),
  _Brand('Lamborghini', 'assets/images/brands/lamborghini.png', 4, 'Expect the unexpected'),
  _Brand('Range Rover', 'assets/images/brands/range-rover.png', 14, 'Above and beyond'),
  _Brand('Lexus', 'assets/images/brands/lexus.png', 11, 'Experience amazing'),
  _Brand('Nissan', 'assets/images/brands/nissan.png', 32, 'Innovation that excites'),
  _Brand('Hyundai', 'assets/images/brands/hyundai.png', 27, 'New thinking'),
];

// ============================================================
// BRANDS SCREEN
// ============================================================

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  List<_Brand> get _filtered {
    if (_query.trim().isEmpty) return _allBrands;
    return _allBrands.where((b) => b.name.toLowerCase().contains(_query.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  // MOBILE
  // ==========================================================================

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final brands = _filtered;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(isDark, cs),
        SliverToBoxAdapter(child: _buildSearchField(isDark, cs, padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 12.r))),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: Text(
              '${brands.length} ${'brands_count'.tr()}',
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 32.r),
          sliver: brands.isEmpty
              ? SliverFillRemaining(child: _buildEmpty(isDark, cs))
              : SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.r,
                    mainAxisSpacing: 12.r,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _BrandTile(brand: brands[i], isDark: isDark, cs: cs),
                    childCount: brands.length,
                  ),
                ),
        ),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP
  // ==========================================================================

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final brands = _filtered;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 18.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 14.r),
                  Text(
                    'brands_title'.tr(),
                    style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                  const Spacer(),
                  SizedBox(width: 360.r, child: _buildSearchField(isDark, cs)),
                ],
              ),
              SizedBox(height: 20.r),
              Text(
                '${brands.length} ${'brands_count'.tr()}',
                style: TextStyle(
                  fontSize: 13.r,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.r),
              brands.isEmpty
                  ? SizedBox(height: 420.r, child: _buildEmpty(isDark, cs))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 16.r,
                        mainAxisSpacing: 16.r,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: brands.length,
                      itemBuilder: (_, i) => _BrandTile(brand: brands[i], isDark: isDark, cs: cs),
                    ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // APP BAR (mobile)
  // ==========================================================================

  Widget _buildAppBar(bool isDark, ColorScheme cs) {
    return SliverAppBar(
      pinned: true,
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
        'brands_title'.tr(),
        style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
      ),
    );
  }

  // ==========================================================================
  // SEARCH FIELD
  // ==========================================================================

  Widget _buildSearchField(bool isDark, ColorScheme cs, {EdgeInsets? padding}) {
    final field = ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 48.r,
          padding: EdgeInsets.symmetric(horizontal: 14.r),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.5)),
              SizedBox(width: 10.r),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(fontSize: 14.r, color: cs.onSurface),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.r),
                    hintText: 'brands_search_hint'.tr(),
                    hintStyle: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  child: Icon(Iconsax.close_circle_copy, size: 16.r, color: cs.onSurface.withValues(alpha: 0.4)),
                ),
            ],
          ),
        ),
      ),
    );

    return padding != null ? Padding(padding: padding, child: field) : field;
  }

  // ==========================================================================
  // EMPTY
  // ==========================================================================

  Widget _buildEmpty(bool isDark, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.08),
            ),
            child: Icon(Iconsax.search_normal_copy, size: 32.r, color: cs.primary.withValues(alpha: 0.6)),
          ),
          SizedBox(height: 14.r),
          Text(
            'brands_empty_title'.tr(),
            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          SizedBox(height: 4.r),
          Text(
            'brands_empty_subtitle'.tr(),
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BRAND TILE
// ============================================================

class _BrandTile extends StatelessWidget {
  final _Brand brand;
  final bool isDark;
  final ColorScheme cs;

  const _BrandTile({required this.brand, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed('car-listing', extra: {'brand': brand.name}),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 14.r,
                  offset: Offset(0, 4.r),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo disc
                  Container(
                    width: 54.r,
                    height: 54.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Image.asset(
                          brand.logoAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              brand.name[0],
                              style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    brand.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  SizedBox(height: 3.r),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 2.r),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${brand.carsCount} ${'brands_cars'.tr()}',
                      style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w700),
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
