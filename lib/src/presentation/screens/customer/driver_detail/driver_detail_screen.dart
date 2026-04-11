import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../../widgets/omr_icon.dart';
import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';

// ============================================================
// DRIVER DETAIL SCREEN
// ============================================================

class DriverDetailScreen extends StatefulWidget {
  final String driverId;
  const DriverDetailScreen({super.key, required this.driverId});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  bool _isFavourite = false;

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  // Mock data
  static const _name = 'Rashid Al-Suleimani';
  static const _avatar = 'https://randomuser.me/api/portraits/men/32.jpg';
  static const _rating = 4.9;
  static const _trips = 312;
  static const _years = 8;
  static const _pricePerDay = 80.0;
  static const _specialities = ['Chauffeur', 'Airport', 'VIP'];
  static const _languages = ['English', 'Arabic', 'Hindi'];
  static const _about =
      'Professional chauffeur with over 8 years of experience serving clients across Oman. Specializing in VIP and corporate transportation, I pride myself on punctuality, discretion, and providing a premium driving experience. Fluent in multiple languages to accommodate international guests.';

  static const _reviews = [
    (
      'Sarah M.',
      5.0,
      'Excellent service! Rashid was punctual, professional, and made our airport transfer smooth.',
      '2 days ago',
    ),
    ('James T.', 4.8, 'Very knowledgeable about the city. Great conversation and safe driving.', '1 week ago'),
    ('Fatima A.', 5.0, 'Best driver experience in Oman. Highly recommend for VIP services.', '2 weeks ago'),
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
            // Pinned SliverAppBar with gradient header as flexible space
            SliverAppBar(
              pinned: true,
              expandedHeight: 280.r,
              toolbarHeight: 56.r,
              automaticallyImplyLeading: false,
              backgroundColor: isDark ? const Color(0xFF1A237E) : const Color(0xFF0C2485),
              surfaceTintColor: Colors.transparent,
              title: Text(
                _name,
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
                    child: Icon(CupertinoIcons.back, size: 18.r, color: Colors.white),
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
              flexibleSpace: FlexibleSpaceBar(background: _buildProfileHeaderForSliver(isDark, cs)),
            ),
            // Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                child: _buildStatsRow(isDark, cs),
              ),
            ),
            // Specialities
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 0),
                child: _buildSpecialitiesSection(isDark, cs),
              ),
            ),
            // About
            SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0), child: _buildAboutSection(isDark, cs)),
            ),
            // Languages
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0),
                child: _buildLanguagesSection(isDark, cs),
              ),
            ),
            // Reviews
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, 14.r, 16.r, 0),
                child: _buildReviewsSection(isDark, cs),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
        // Bottom hire bar
        Positioned(left: 0, right: 0, bottom: 0, child: _buildHireBar(isDark, cs)),
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
                      child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                    ),
                    SizedBox(width: 10.r),
                    Text(
                      _name,
                      style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildProfileHeader(isDark, cs, isDesktop: true),
                        SizedBox(height: 16.r),
                        _buildStatsRow(isDark, cs),
                        SizedBox(height: 4.r),
                        _buildSpecialitiesSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildLanguagesSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildDesktopHireButton(isDark, cs),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.r),
                  // Right column
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildAboutSection(isDark, cs),
                        SizedBox(height: 16.r),
                        _buildReviewsSection(isDark, cs),
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
  // PROFILE HEADER
  // ==========================================================================

  Widget _buildProfileHeaderForSliver(bool isDark, ColorScheme cs) {
    return Container(
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
        children: [
          // Decorative circles
          Positioned(right: -30.r, top: -40.r, child: _circle(160.r, 0.06)),
          Positioned(left: -40.r, bottom: -50.r, child: _circle(120.r, 0.04)),
          Positioned(right: 60.r, bottom: -20.r, child: _circle(80.r, 0.03)),
          // Content – centered avatar, name, availability
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.r),
                CachedNetworkImage(
                  imageUrl: _avatar,
                  imageBuilder: (_, img) => Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                      image: DecorationImage(image: img, fit: BoxFit.cover),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20.r, offset: Offset(0, 8.r)),
                      ],
                    ),
                  ),
                  placeholder: (_, __) => Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                    ),
                    child: Icon(Iconsax.user, size: 32.r, color: Colors.white54),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                    ),
                    child: Icon(Iconsax.user, size: 32.r, color: Colors.white54),
                  ),
                ),
                SizedBox(height: 12.r),
                Text(
                  _name,
                  style: TextStyle(
                    fontSize: 19.r,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 6.r),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 5.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                      ),
                      SizedBox(width: 6.r),
                      Text(
                        'driver_detail_available'.tr(),
                        style: TextStyle(fontSize: 11.r, color: const Color(0xFF81C784), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, ColorScheme cs, {bool isDesktop = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: isDesktop ? BorderRadius.circular(24.r) : null,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: const Color(0xFF0C2485).withValues(alpha: 0.3),
                  blurRadius: 24.r,
                  offset: Offset(0, 8.r),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: isDesktop ? BorderRadius.circular(24.r) : BorderRadius.zero,
        child: Stack(
          children: [
            // Decorative
            Positioned(right: -30.r, top: -40.r, child: _circle(160.r, 0.06)),
            Positioned(left: -40.r, bottom: -50.r, child: _circle(120.r, 0.04)),
            Positioned(right: 60.r, bottom: -20.r, child: _circle(80.r, 0.03)),
            // Top buttons
            if (!isDesktop)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8.r,
                left: 16.r,
                right: 16.r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _headerButton(CupertinoIcons.back, () => Navigator.of(context).pop()),
                    _headerButton(
                      _isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                      () => setState(() => _isFavourite = !_isFavourite),
                      iconColor: _isFavourite ? const Color(0xFFE91E63) : null,
                    ),
                  ],
                ),
              ),
            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(
                24.r,
                isDesktop ? 28.r : (MediaQuery.of(context).padding.top + 56.r),
                24.r,
                28.r,
              ),
              child: Column(
                children: [
                  // Avatar
                  CachedNetworkImage(
                    imageUrl: _avatar,
                    imageBuilder: (_, img) => Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                        image: DecorationImage(image: img, fit: BoxFit.cover),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20.r,
                            offset: Offset(0, 8.r),
                          ),
                        ],
                      ),
                    ),
                    placeholder: (_, __) => Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                      ),
                      child: Icon(Iconsax.user, size: 32.r, color: Colors.white54),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                      ),
                      child: Icon(Iconsax.user, size: 32.r, color: Colors.white54),
                    ),
                  ),
                  SizedBox(height: 12.r),
                  Text(
                    _name,
                    style: TextStyle(
                      fontSize: 19.r,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 6.r),
                  // Availability badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 5.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                        ),
                        SizedBox(width: 6.r),
                        Text(
                          'driver_detail_available'.tr(),
                          style: TextStyle(fontSize: 11.r, color: const Color(0xFF81C784), fontWeight: FontWeight.w600),
                        ),
                      ],
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

  Widget _headerButton(IconData icon, VoidCallback onTap, {Color? iconColor}) {
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
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(icon, size: 18.r, color: iconColor ?? Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }

  // ==========================================================================
  // STATS ROW
  // ==========================================================================

  Widget _buildStatsRow(bool isDark, ColorScheme cs) {
    final stats = [
      ('$_rating', 'driver_detail_rating'.tr(), const Color(0xFFFFC107)),
      ('$_trips', 'driver_detail_trips'.tr(), const Color(0xFF3D5AFE)),
      ('$_years', 'driver_detail_years'.tr(), const Color(0xFF7C4DFF)),
    ];

    return Transform.translate(
      offset: Offset(0, -14.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.92),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 20.r,
                  offset: Offset(0, 6.r),
                ),
              ],
            ),
            child: Row(
              children: stats.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.r),
                    decoration: BoxDecoration(
                      border: i < stats.length - 1
                          ? Border(
                              right: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.$1,
                          style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: s.$3),
                        ),
                        SizedBox(height: 3.r),
                        Text(
                          s.$2,
                          style: TextStyle(
                            fontSize: 10.r,
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
        ),
      ),
    );
  }

  // ==========================================================================
  // SPECIALITIES
  // ==========================================================================

  Widget _buildSpecialitiesSection(bool isDark, ColorScheme cs) {
    final colors = [const Color(0xFF3D5AFE), const Color(0xFF7C4DFF), const Color(0xFF00BCD4)];

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
                  child: Icon(Iconsax.medal_star, size: 14.r, color: const Color(0xFF00BCD4)),
                ),
                SizedBox(width: 8.r),
                Text(
                  'driver_detail_specialities'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: _specialities.asMap().entries.map((e) {
                final col = colors[e.key % colors.length];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                  decoration: BoxDecoration(
                    color: col.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: col.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: col),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ABOUT
  // ==========================================================================

  Widget _buildAboutSection(bool isDark, ColorScheme cs) {
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
                  child: Icon(Iconsax.info_circle, size: 14.r, color: const Color(0xFF3D5AFE)),
                ),
                SizedBox(width: 8.r),
                Text(
                  'driver_detail_about'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ],
            ),
            SizedBox(height: 10.r),
            Text(
              _about,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // LANGUAGES
  // ==========================================================================

  Widget _buildLanguagesSection(bool isDark, ColorScheme cs) {
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
                  child: Icon(Iconsax.language_circle, size: 14.r, color: const Color(0xFF7C4DFF)),
                ),
                SizedBox(width: 8.r),
                Text(
                  'driver_detail_languages'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: _languages
                  .map(
                    (l) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 7.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.global, size: 13.r, color: const Color(0xFF7C4DFF)),
                          SizedBox(width: 6.r),
                          Text(
                            l,
                            style: TextStyle(
                              fontSize: 12.r,
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
  // REVIEWS
  // ==========================================================================

  Widget _buildReviewsSection(bool isDark, ColorScheme cs) {
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
                    color: const Color(0xFFFFC107).withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Iconsax.message_text, size: 14.r, color: const Color(0xFFFFC107)),
                ),
                SizedBox(width: 8.r),
                Text(
                  'driver_detail_reviews'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                const Spacer(),
                Text(
                  '${_reviews.length} reviews',
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
                ),
              ],
            ),
            SizedBox(height: 14.r),
            ...List.generate(_reviews.length, (i) {
              final r = _reviews[i];
              return Column(
                children: [
                  if (i > 0)
                    Divider(
                      height: 20.r,
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            r.$1[0],
                            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.primary),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.r),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  r.$1,
                                  style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                                ),
                                const Spacer(),
                                Text(
                                  r.$4,
                                  style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.35)),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.r),
                            Row(
                              children: List.generate(
                                5,
                                (si) => Padding(
                                  padding: EdgeInsets.only(right: 2.r),
                                  child: Icon(
                                    si < r.$2.round() ? Iconsax.star_1_copy : Iconsax.star_1,
                                    size: 11.r,
                                    color: const Color(0xFFFFC107),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 6.r),
                            Text(
                              r.$3,
                              style: TextStyle(
                                fontSize: 11.r,
                                color: cs.onSurface.withValues(alpha: 0.55),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HIRE BAR (mobile)
  // ==========================================================================

  Widget _buildHireBar(bool isDark, ColorScheme cs) {
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
                    'Rate',
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
                        '${_pricePerDay.toInt()}${'driver_detail_per_day'.tr()}',
                        style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.primary),
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
                    'driver_detail_hire'.tr(),
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
  // DESKTOP HIRE BUTTON
  // ==========================================================================

  Widget _buildDesktopHireButton(bool isDark, ColorScheme cs) {
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'driver_detail_hire'.tr(),
                style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              SizedBox(width: 8.r),
              Text(
                '·',
                style: TextStyle(fontSize: 15.r, color: Colors.white54),
              ),
              SizedBox(width: 8.r),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OmrIcon(size: 11.r, color: Colors.white70),
                  SizedBox(width: 3.r),
                  Text(
                    '${_pricePerDay.toInt()}${'driver_detail_per_day'.tr()}',
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                ],
              ),
            ],
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
