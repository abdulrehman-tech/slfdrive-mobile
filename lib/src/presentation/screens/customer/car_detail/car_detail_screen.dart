import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../widgets/omr_icon.dart';
import 'package:provider/provider.dart';
import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';

// ============================================================
// CAR DETAIL SCREEN
// ============================================================

class CarDetailScreen extends StatefulWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavourite = false;

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  // Mock data
  static const _images = [
    'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800&q=80',
    'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800&q=80',
  ];

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

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Pinned SliverAppBar with image gallery as flexible space
            SliverAppBar(
              pinned: true,
              expandedHeight: 300.r,
              toolbarHeight: 56.r,
              automaticallyImplyLeading: false,
              backgroundColor: isDark ? const Color(0xFF0C2485) : const Color(0xFF0C2485),
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Mercedes AMG GT',
                style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Iconsax.arrow_left_2, size: 18.r, color: Colors.white),
                  ),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => setState(() => _isFavourite = !_isFavourite),
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.r),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        _isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                        size: 18.r,
                        color: _isFavourite ? const Color(0xFFE91E63) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(background: _buildImageGalleryForSliver(isDark, cs)),
            ),
            // Car info header
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0), child: _buildCarInfoHeader(isDark, cs)),
            ),
            // Specs
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: _buildSpecsSection(isDark, cs)),
            ),
            // Features
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0),
                child: _buildFeaturesSection(isDark, cs),
              ),
            ),
            // Description
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0),
                child: _buildDescriptionSection(isDark, cs),
              ),
            ),
            // Owner
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: _buildOwnerSection(isDark, cs)),
            ),
            // Location
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0),
                child: _buildLocationSection(isDark, cs),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
        // Bottom booking bar
        Positioned(left: 0, right: 0, bottom: 0, child: _buildBookingBar(isDark, cs)),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT
  // ==========================================================================

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Iconsax.arrow_left_2, size: 17.r, color: cs.onSurface),
                    ),
                    SizedBox(width: 10.r),
                    Text(
                      'Mercedes AMG GT',
                      style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: images + description
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildImageGallery(isDark, cs, isDesktop: true),
                        SizedBox(height: 20.r),
                        _buildDescriptionSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildOwnerSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildLocationSection(isDark, cs),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.r),
                  // Right: info + specs + features + book
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildCarInfoHeader(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildSpecsSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildFeaturesSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildDesktopBookButton(isDark, cs),
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

  // ==========================================================================
  // IMAGE GALLERY
  // ==========================================================================

  Widget _buildImageGalleryForSliver(bool isDark, ColorScheme cs) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: _images.length,
          onPageChanged: (i) => setState(() => _currentImageIndex = i),
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: _images[i],
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0)),
            errorWidget: (_, __, ___) => Container(
              color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
              child: Center(
                child: Icon(Iconsax.car_copy, size: 40.r, color: cs.primary.withValues(alpha: 0.3)),
              ),
            ),
          ),
        ),
        // Gradient overlay at bottom for dots readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 50.r,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
              ),
            ),
          ),
        ),
        // Page dots
        Positioned(
          bottom: 12.r,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_images.length, (i) {
              final active = i == _currentImageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.symmetric(horizontal: 3.r),
                width: active ? 20.r : 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(bool isDark, ColorScheme cs, {bool isDesktop = false}) {
    final height = isDesktop ? 340.r : 280.r;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: isDesktop ? BorderRadius.circular(20.r) : BorderRadius.zero,
          child: SizedBox(
            height: height,
            child: PageView.builder(
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: _images[i],
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0)),
                errorWidget: (_, __, ___) => Container(
                  color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                  child: Center(
                    child: Icon(Iconsax.car_copy, size: 40.r, color: cs.primary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Top overlay buttons (back + fav)
        if (!isDesktop)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.r,
            left: 16.r,
            right: 16.r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassButton(Iconsax.arrow_left_2, isDark, () => Navigator.of(context).pop()),
                _glassButton(
                  _isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                  isDark,
                  () => setState(() => _isFavourite = !_isFavourite),
                  iconColor: _isFavourite ? const Color(0xFFE91E63) : null,
                ),
              ],
            ),
          ),
        // Page dots
        Positioned(
          bottom: 12.r,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_images.length, (i) {
              final active = i == _currentImageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.symmetric(horizontal: 3.r),
                width: active ? 20.r : 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _glassButton(IconData icon, bool isDark, VoidCallback onTap, {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(icon, size: 18.r, color: iconColor ?? (isDark ? Colors.white : Colors.black87)),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // CAR INFO HEADER
  // ==========================================================================

  Widget _buildCarInfoHeader(bool isDark, ColorScheme cs) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mercedes AMG GT',
                    style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Available',
                    style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.r),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Mercedes',
                    style: TextStyle(fontSize: 10.r, color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(width: 10.r),
                Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 14.r),
                SizedBox(width: 4.r),
                Text(
                  '4.9',
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(width: 4.r),
                Text(
                  '(128 reviews)',
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.45)),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OmrIcon(size: 16.r, color: cs.primary),
                    SizedBox(width: 3.r),
                    Text(
                      '250',
                      style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.primary),
                    ),
                    Text(
                      'car_detail_per_day'.tr(),
                      style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Iconsax.location, size: 14.r, color: cs.onSurface.withValues(alpha: 0.4)),
                SizedBox(width: 4.r),
                Text(
                  'Muscat, Oman',
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SPECS SECTION
  // ==========================================================================

  Widget _buildSpecsSection(bool isDark, ColorScheme cs) {
    final specs = [
      (Iconsax.people, 'car_detail_seats'.tr(), '2', const Color(0xFF3D5AFE)),
      (Iconsax.cpu_setting, 'car_detail_transmission'.tr(), 'Automatic', const Color(0xFF7C4DFF)),
      (Iconsax.gas_station, 'car_detail_fuel'.tr(), 'Petrol', const Color(0xFF00BCD4)),
      (Iconsax.calendar_1, 'car_detail_year'.tr(), '2024', const Color(0xFFFFC107)),
      (Iconsax.colorfilter, 'car_detail_color'.tr(), 'Silver', const Color(0xFFE91E63)),
      (Iconsax.cpu, 'car_detail_engine'.tr(), '4.0L V8', const Color(0xFF4CAF50)),
    ];

    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE).withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Iconsax.cpu_setting, size: 14.r, color: const Color(0xFF3D5AFE)),
                ),
                SizedBox(width: 8.r),
                Text(
                  'car_detail_specs'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ],
            ),
            SizedBox(height: 14.r),
            Wrap(
              spacing: 10.r,
              runSpacing: 10.r,
              children: specs
                  .map(
                    (s) => Container(
                      width: (MediaQuery.of(context).size.width - 80.r) / 3,
                      constraints: BoxConstraints(minWidth: 90.r),
                      padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: 8.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.025),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              color: s.$4.withValues(alpha: isDark ? 0.12 : 0.08),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(s.$1, size: 14.r, color: s.$4),
                          ),
                          SizedBox(height: 6.r),
                          Text(
                            s.$3,
                            style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                          ),
                          SizedBox(height: 2.r),
                          Text(
                            s.$2,
                            style: TextStyle(
                              fontSize: 9.r,
                              color: cs.onSurface.withValues(alpha: 0.45),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // FEATURES SECTION
  // ==========================================================================

  Widget _buildFeaturesSection(bool isDark, ColorScheme cs) {
    final features = [
      'GPS Navigation',
      'Bluetooth',
      'Leather Seats',
      'Sunroof',
      'Heated Seats',
      'Cruise Control',
      'Backup Camera',
      'Keyless Entry',
    ];

    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Iconsax.magic_star, size: 14.r, color: const Color(0xFF7C4DFF)),
                ),
                SizedBox(width: 8.r),
                Text(
                  'car_detail_features'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: features
                  .map(
                    (f) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.tick_circle, size: 12.r, color: const Color(0xFF4CAF50)),
                          SizedBox(width: 5.r),
                          Text(
                            f,
                            style: TextStyle(
                              fontSize: 11.r,
                              color: cs.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // DESCRIPTION SECTION
  // ==========================================================================

  Widget _buildDescriptionSection(bool isDark, ColorScheme cs) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
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
                  child: Icon(Iconsax.document_text, size: 14.r, color: const Color(0xFF00BCD4)),
                ),
                SizedBox(width: 8.r),
                Text(
                  'car_detail_description'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ],
            ),
            SizedBox(height: 10.r),
            Text(
              'Experience the thrill of driving the iconic Mercedes AMG GT. This stunning sports car combines breathtaking performance with luxurious comfort. Perfect for special occasions, weekend adventures, or simply making a statement on the road.',
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // OWNER SECTION
  // ==========================================================================

  Widget _buildOwnerSection(bool isDark, ColorScheme cs) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)]),
              ),
              child: Center(
                child: Text(
                  'A',
                  style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ahmed Al-Balushi',
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  SizedBox(height: 2.r),
                  Row(
                    children: [
                      Icon(Iconsax.star_1_copy, size: 12.r, color: const Color(0xFFFFC107)),
                      SizedBox(width: 3.r),
                      Text(
                        '4.9  ·  24 cars listed',
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Iconsax.message, size: 16.r, color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // LOCATION SECTION
  // ==========================================================================

  Widget _buildLocationSection(bool isDark, ColorScheme cs) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Iconsax.location, size: 14.r, color: const Color(0xFFE91E63)),
                ),
                SizedBox(width: 8.r),
                Text(
                  'car_detail_location'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            // Map placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                height: 140.r,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.map, size: 28.r, color: cs.onSurface.withValues(alpha: 0.2)),
                      SizedBox(height: 6.r),
                      Text(
                        'Muscat, Oman',
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BOOKING BAR (mobile)
  // ==========================================================================

  Widget _buildBookingBar(bool isDark, ColorScheme cs) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 14.r + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 10.r,
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OmrIcon(size: 15.r, color: cs.primary),
                      SizedBox(width: 3.r),
                      Text(
                        '250',
                        style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.primary),
                      ),
                      Text(
                        'car_detail_per_day'.tr(),
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 14.r),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                        blurRadius: 14.r,
                        offset: Offset(0, 5.r),
                      ),
                    ],
                  ),
                  child: Text(
                    'car_detail_book'.tr(),
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: Colors.white),
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
  // DESKTOP BOOK BUTTON
  // ==========================================================================

  Widget _buildDesktopBookButton(bool isDark, ColorScheme cs) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.r),
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0C2485).withValues(alpha: 0.35), blurRadius: 16.r, offset: Offset(0, 6.r)),
          ],
        ),
        child: Center(
          child: Text(
            'car_detail_book'.tr(),
            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GLASS CARD
// ============================================================

class _GlassCard extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _GlassCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 16.r,
                offset: Offset(0, 4.r),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
