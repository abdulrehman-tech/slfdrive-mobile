import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/contact_launcher.dart';
import '../../../widgets/omr_icon.dart';
import '../booking/models/booking_data.dart';

// ============================================================
// DRIVER DETAIL SCREEN — PROFESSIONAL REDESIGN
// ============================================================

class DriverDetailScreen extends StatefulWidget {
  final String driverId;
  const DriverDetailScreen({super.key, required this.driverId});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  bool _isFavourite = false;

  // Mock data
  static const _name = 'Rashid Al-Suleimani';
  static const _coverUrl = 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=1200&q=80';
  static const _avatar = 'https://randomuser.me/api/portraits/men/32.jpg';
  static const _rating = 4.9;
  static const _trips = 312;
  static const _years = 8;
  static const _responseTime = '< 2m';
  static const _hourlyRate = 15.0;
  static const _dailyRate = 80.0;
  static const _weeklyRate = 480.0;
  static const _phone = '+96890000001';
  static const _bio =
      'Licensed professional chauffeur with 8+ years serving Oman. Specialising in corporate, airport and VIP transport. Multilingual and fully insured.';

  static const _languages = ['English', 'Arabic', 'Hindi', 'Urdu'];

  static const _services = <(IconData, String, Color)>[
    (Iconsax.car_copy, 'driver_service_chauffeur', Color(0xFF3D5AFE)),
    (Iconsax.airplane_copy, 'driver_service_airport', Color(0xFF7C4DFF)),
    (Iconsax.map_1_copy, 'driver_service_city', Color(0xFF00BCD4)),
    (Iconsax.route_square_copy, 'driver_service_long', Color(0xFF4CAF50)),
    (Iconsax.crown_copy, 'driver_service_vip', Color(0xFFFFC107)),
    (Iconsax.heart_copy, 'driver_service_wedding', Color(0xFFE91E63)),
  ];

  static const _vehicles = <(IconData, String, Color)>[
    (Iconsax.car_copy, 'Sedan', Color(0xFF3D5AFE)),
    (Iconsax.truck_copy, 'SUV', Color(0xFF7C4DFF)),
    (Iconsax.bus_copy, 'Van', Color(0xFF00BCD4)),
  ];

  // Weekly availability (mon-sun) — mock
  static const _availability = <(String, bool)>[
    ('M', true),
    ('T', true),
    ('W', false),
    ('T', true),
    ('F', true),
    ('S', true),
    ('S', false),
  ];

  // Review distribution (5-1 star counts) — mock
  static const _reviewCounts = [210, 72, 18, 7, 5];

  // Individual reviews — mock
  static const _reviews = <(String, double, String, String)>[
    ('Sarah M.', 5.0, 'Excellent service — punctual, professional, and smooth airport transfer.', '2 days ago'),
    ('James T.', 4.8, 'Knows the city well, great conversation and safe driving throughout.', '1 week ago'),
    ('Fatima A.', 5.0, 'Best driver experience in Oman. Highly recommend for VIP services.', '2 weeks ago'),
  ];

  bool get _isDark {
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  int get _totalReviews => _reviewCounts.fold(0, (a, b) => a + b);

  // Scroll-driven glass header
  final ScrollController _scroll = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final next = _scroll.offset.clamp(0, 240).toDouble();
    if ((next - _scrollOffset).abs() > 0.5) setState(() => _scrollOffset = next);
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

    return Stack(
      children: [
        CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildCoverHeader(cs, isDark)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 120.r),
              sliver: SliverList.list(
                children: [
                  _buildStatsCard(cs, isDark),
                  SizedBox(height: 14.r),
                  _buildTrustCard(cs, isDark),
                  SizedBox(height: 14.r),
                  _buildPricingCard(cs, isDark),
                  SizedBox(height: 14.r),
                  _buildAboutCard(cs, isDark),
                  SizedBox(height: 14.r),
                  _buildServicesCard(cs, isDark),
                  SizedBox(height: 14.r),
                  _buildVehiclesCard(cs, isDark),
                  SizedBox(height: 14.r),
                  _buildAvailabilityCard(cs, isDark),
                  SizedBox(height: 14.r),
                  _buildLanguagesCard(cs, isDark),
                  SizedBox(height: 14.r),
                  _buildReviewsCard(cs, isDark),
                ],
              ),
            ),
          ],
        ),
        // Glass header that fades in on scroll
        Positioned(left: 0, right: 0, top: 0, child: _buildGlassHeaderOverlay(cs, isDark)),
        Positioned(left: 0, right: 0, bottom: 0, child: _buildHireBar(cs, isDark)),
      ],
    );
  }

  Widget _buildGlassHeaderOverlay(ColorScheme cs, bool isDark) {
    final topPad = MediaQuery.of(context).padding.top;
    final t = (_scrollOffset / 180).clamp(0.0, 1.0);
    return IgnorePointer(
      ignoring: t < 0.35,
      child: Opacity(
        opacity: t,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.fromLTRB(12.r, topPad + 6.r, 12.r, 10.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.74) : Colors.white.withValues(alpha: 0.82),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 16.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w800, color: cs.onSurface),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isFavourite = !_isFavourite),
                    child: Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(
                        _isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                        size: 16.r,
                        color: _isFavourite ? const Color(0xFFE91E63) : cs.onSurface,
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

  // ==========================================================================
  // DESKTOP
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
                      child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 14.r),
                  Text(
                    'driver_detail_title'.tr(),
                    style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ],
              ),
              SizedBox(height: 20.r),
              _buildCoverHeader(cs, isDark, isDesktop: true),
              SizedBox(height: 20.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildStatsCard(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildAboutCard(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildServicesCard(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildReviewsCard(cs, isDark),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.r),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildTrustCard(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildPricingCard(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildVehiclesCard(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildAvailabilityCard(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildLanguagesCard(cs, isDark),
                        SizedBox(height: 16.r),
                        _buildDesktopHireButton(cs),
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
  // HEADER (cover + avatar overlap)
  // ==========================================================================

  Widget _buildCoverHeader(ColorScheme cs, bool isDark, {bool isDesktop = false}) {
    return Container(
      margin: isDesktop ? EdgeInsets.zero : EdgeInsets.zero,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover photo
          Container(
            height: isDesktop ? 200.r : 230.r,
            decoration: BoxDecoration(
              borderRadius: isDesktop ? BorderRadius.circular(20.r) : null,
              image: DecorationImage(
                image: CachedNetworkImageProvider(_coverUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: isDesktop ? BorderRadius.circular(20.r) : null,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                ),
              ),
            ),
          ),
          // Top bar (mobile only)
          if (!isDesktop)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.r,
              left: 16.r,
              right: 16.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _glassButton(CupertinoIcons.back, () => Navigator.of(context).pop()),
                  Row(
                    children: [
                      _glassButton(Iconsax.share_copy, () {}),
                      SizedBox(width: 8.r),
                      _glassButton(
                        _isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                        () => setState(() => _isFavourite = !_isFavourite),
                        iconColor: _isFavourite ? const Color(0xFFE91E63) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Identity block (overlapping bottom)
          Positioned(left: 16.r, right: 16.r, bottom: -48.r, child: _buildIdentityCard(cs, isDark)),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(ColorScheme cs, bool isDark) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary.withValues(alpha: 0.4), width: 3),
                    boxShadow: [
                      BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 14.r, offset: Offset(0, 5.r)),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _avatar,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFEEEEEE),
                        child: Icon(Iconsax.user_copy, size: 30.r, color: cs.primary),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 2.r,
                  bottom: 2.r,
                  child: Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF1A1A28) : Colors.white, width: 2.5),
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _name,
                          style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.r),
                      Icon(Iconsax.verify_copy, size: 16.r, color: cs.primary),
                    ],
                  ),
                  SizedBox(height: 6.r),
                  Wrap(
                    spacing: 6.r,
                    runSpacing: 4.r,
                    children: [
                      _tinyChip(
                        Iconsax.tick_circle_copy,
                        'driver_detail_verified_id'.tr(),
                        const Color(0xFF4CAF50),
                        isDark,
                      ),
                      _tinyChip(
                        Iconsax.driver_copy,
                        'driver_detail_verified_license'.tr(),
                        const Color(0xFF3D5AFE),
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 5.r),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  ),
                  SizedBox(width: 5.r),
                  Text(
                    'driver_detail_available'.tr(),
                    style: TextStyle(fontSize: 10.r, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w800),
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
  // CARDS
  // ==========================================================================

  Widget _buildStatsCard(ColorScheme cs, bool isDark) {
    final stats = <(String, String, IconData, Color)>[
      ('$_rating', 'driver_detail_rating'.tr(), Iconsax.star_1_copy, const Color(0xFFFFC107)),
      ('$_trips', 'driver_detail_trips'.tr(), Iconsax.route_square_copy, const Color(0xFF3D5AFE)),
      ('$_years', 'driver_detail_years'.tr(), Iconsax.calendar_tick_copy, const Color(0xFF7C4DFF)),
      (_responseTime, 'driver_detail_response'.tr(), Iconsax.timer_1_copy, const Color(0xFF4CAF50)),
    ];
    // On mobile, align top-tier identity card (which floats -48 below) with
    // the stats card by pushing it down.
    return Padding(
      padding: EdgeInsets.only(top: 48.r),
      child: _glassCard(
        isDark,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.r, horizontal: 8.r),
          child: Row(
            children: stats.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              return Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.r),
                  decoration: BoxDecoration(
                    border: i < stats.length - 1
                        ? Border(
                            right: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.$3, size: 17.r, color: s.$4),
                      SizedBox(height: 5.r),
                      Text(
                        s.$1,
                        style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w900, color: cs.onSurface),
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        s.$2,
                        style: TextStyle(
                          fontSize: 9.r,
                          color: cs.onSurface.withValues(alpha: 0.55),
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
    );
  }

  Widget _buildTrustCard(ColorScheme cs, bool isDark) {
    final items = <(IconData, String, Color)>[
      (Iconsax.tick_circle_copy, 'driver_trust_background', const Color(0xFF4CAF50)),
      (Iconsax.shield_tick_copy, 'driver_trust_insured', const Color(0xFF3D5AFE)),
      (Iconsax.personalcard_copy, 'driver_trust_licensed', const Color(0xFF7C4DFF)),
      (Iconsax.heart_add_copy, 'driver_trust_safety', const Color(0xFFE91E63)),
    ];
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(cs, Iconsax.security_safe_copy, const Color(0xFF4CAF50), 'driver_detail_trust'.tr(), isDark),
            SizedBox(height: 12.r),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8.r,
              mainAxisSpacing: 8.r,
              childAspectRatio: 2.8,
              children: items.map((e) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: e.$3.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(e.$1, size: 14.r, color: e.$3),
                      SizedBox(width: 6.r),
                      Expanded(
                        child: Text(
                          e.$2.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(ColorScheme cs, bool isDark) {
    final tiers = <(String, double, String)>[
      ('driver_price_hourly', _hourlyRate, 'hr'),
      ('driver_price_daily', _dailyRate, 'day'),
      ('driver_price_weekly', _weeklyRate, 'wk'),
    ];
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              cs,
              Iconsax.money_recive_copy,
              const Color(0xFF4CAF50),
              'driver_detail_pricing'.tr(),
              isDark,
            ),
            SizedBox(height: 12.r),
            Row(
              children: tiers.asMap().entries.map((e) {
                final i = e.key;
                final t = e.value;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < tiers.length - 1 ? 8.r : 0),
                    padding: EdgeInsets.symmetric(vertical: 12.r, horizontal: 8.r),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          t.$1.tr(),
                          style: TextStyle(
                            fontSize: 10.r,
                            color: cs.onSurface.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6.r),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OmrIcon(size: 11.r, color: cs.primary),
                            SizedBox(width: 2.r),
                            Text(
                              t.$2.toStringAsFixed(0),
                              style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w900, color: cs.primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.r),
                        Text(
                          '/${t.$3}',
                          style: TextStyle(fontSize: 9.r, color: cs.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(ColorScheme cs, bool isDark) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(cs, Iconsax.info_circle_copy, const Color(0xFF3D5AFE), 'driver_detail_about'.tr(), isDark),
            SizedBox(height: 10.r),
            Text(
              _bio,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.65), height: 1.55),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(ColorScheme cs, bool isDark) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(cs, Iconsax.medal_star_copy, const Color(0xFF00BCD4), 'driver_detail_services'.tr(), isDark),
            SizedBox(height: 12.r),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8.r,
              mainAxisSpacing: 8.r,
              childAspectRatio: 1.2,
              children: _services.map((e) {
                return Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: e.$3.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(e.$1, size: 20.r, color: e.$3),
                      SizedBox(height: 6.r),
                      Text(
                        e.$2.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesCard(ColorScheme cs, bool isDark) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(cs, Iconsax.car_copy, const Color(0xFF7C4DFF), 'driver_detail_vehicles'.tr(), isDark),
            SizedBox(height: 10.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: _vehicles.map((v) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
                  decoration: BoxDecoration(
                    color: v.$3.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: v.$3.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(v.$1, size: 14.r, color: v.$3),
                      SizedBox(width: 6.r),
                      Text(
                        v.$2,
                        style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: v.$3),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(ColorScheme cs, bool isDark) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              cs,
              Iconsax.calendar_2_copy,
              const Color(0xFF4CAF50),
              'driver_detail_availability'.tr(),
              isDark,
            ),
            SizedBox(height: 12.r),
            Row(
              children: _availability.map((day) {
                final available = day.$2;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.r),
                    child: Column(
                      children: [
                        Text(
                          day.$1,
                          style: TextStyle(
                            fontSize: 10.r,
                            color: cs.onSurface.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6.r),
                        Container(
                          width: double.infinity,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: available
                                ? const Color(0xFF4CAF50).withValues(alpha: isDark ? 0.25 : 0.15)
                                : const Color(0xFFE53935).withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Icon(
                              available ? Iconsax.tick_circle_copy : Iconsax.close_circle_copy,
                              size: 14.r,
                              color: available ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesCard(ColorScheme cs, bool isDark) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              cs,
              Iconsax.language_circle_copy,
              const Color(0xFF00BCD4),
              'driver_detail_languages'.tr(),
              isDark,
            ),
            SizedBox(height: 10.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: _languages.map((l) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.global_copy, size: 13.r, color: const Color(0xFF00BCD4)),
                      SizedBox(width: 6.r),
                      Text(
                        l,
                        style: TextStyle(
                          fontSize: 12.r,
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsCard(ColorScheme cs, bool isDark) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              cs,
              Iconsax.message_text_copy,
              const Color(0xFFFFC107),
              'driver_detail_reviews'.tr(),
              isDark,
            ),
            SizedBox(height: 14.r),
            // Top summary row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '$_rating',
                      style: TextStyle(fontSize: 34.r, fontWeight: FontWeight.w900, color: cs.onSurface, height: 1),
                    ),
                    SizedBox(height: 4.r),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < _rating.round() ? Iconsax.star_1_copy : Iconsax.star_1,
                          size: 11.r,
                          color: const Color(0xFFFFC107),
                        ),
                      ),
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      '$_totalReviews ${'driver_detail_reviews_count'.tr()}',
                      style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
                SizedBox(width: 20.r),
                // Distribution bars
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count = _reviewCounts[i];
                      final frac = _totalReviews == 0 ? 0.0 : count / _totalReviews;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.5.r),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14.r,
                              child: Text(
                                '$star',
                                style: TextStyle(
                                  fontSize: 10.r,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            Icon(Iconsax.star_1_copy, size: 10.r, color: const Color(0xFFFFC107)),
                            SizedBox(width: 6.r),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 6.r,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(alpha: 0.05),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: frac,
                                      child: Container(
                                        height: 6.r,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFC107),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.r),
                            SizedBox(
                              width: 30.r,
                              child: Text(
                                '$count',
                                style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.r),
            Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
            ),
            SizedBox(height: 12.r),
            // Individual reviews
            ..._reviews.asMap().entries.map((e) => _reviewTile(e.value, e.key, cs, isDark)),
            SizedBox(height: 6.r),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 10.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Text(
                    'driver_detail_view_all_reviews'.tr(),
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w800, color: cs.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewTile((String, double, String, String) r, int i, ColorScheme cs, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(top: i == 0 ? 0 : 12.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                r.$1[0],
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: cs.primary),
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
                    Expanded(
                      child: Text(
                        r.$1,
                        style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                    ),
                    Text(
                      r.$4,
                      style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
                SizedBox(height: 2.r),
                Row(
                  children: List.generate(
                    5,
                    (si) => Icon(
                      si < r.$2.round() ? Iconsax.star_1_copy : Iconsax.star_1,
                      size: 10.r,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  r.$3,
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.6), height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HIRE BAR
  // ==========================================================================

  Widget _buildHireBar(ColorScheme cs, bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 12.r + MediaQuery.of(context).padding.bottom),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'driver_detail_from'.tr(),
                    style: TextStyle(
                      fontSize: 10.r,
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OmrIcon(size: 15.r, color: cs.primary),
                      SizedBox(width: 3.r),
                      Text(
                        '${_dailyRate.toInt()}',
                        style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.w900, color: cs.primary),
                      ),
                      Text(
                        '/${'day'.tr()}',
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ContactLauncher.openWhatsApp(
                  _phone,
                  message: 'Hi $_name, I would like to hire you through SLF Drive.',
                ),
                child: Container(
                  width: 48.r,
                  height: 48.r,
                  margin: EdgeInsets.only(right: 8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.35)),
                  ),
                  child: Icon(Iconsax.message_copy, color: const Color(0xFF25D366), size: 19.r),
                ),
              ),
              GestureDetector(
                onTap: () => ContactLauncher.openPhoneCall(_phone),
                child: Container(
                  width: 48.r,
                  height: 48.r,
                  margin: EdgeInsets.only(right: 8.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  child: Icon(Iconsax.call_copy, color: cs.primary, size: 19.r),
                ),
              ),
              GestureDetector(
                onTap: () => _launchHireFlow(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22.r, vertical: 14.r),
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
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHireButton(ColorScheme cs) {
    return GestureDetector(
      onTap: () => _launchHireFlow(context),
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
              Icon(Iconsax.user_octagon_copy, size: 16.r, color: Colors.white),
              SizedBox(width: 6.r),
              Text(
                'driver_detail_hire'.tr(),
                style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w800, color: Colors.white),
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
                    '${_dailyRate.toInt()}/${'day'.tr()}',
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

  // ==========================================================================
  // HIRE ENTRY
  // ==========================================================================

  void _launchHireFlow(BuildContext context) {
    const driver = BookingDriver(
      id: 'driver-1',
      name: _name,
      avatarUrl: _avatar,
      rating: _rating,
      pricePerDay: _dailyRate,
      speciality: 'Chauffeur',
    );
    context.pushNamed('booking', extra: {'service': BookingServiceType.driverOnly, 'driver': driver});
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  Widget _glassCard(bool isDark, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
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

  Widget _sectionHeader(ColorScheme cs, IconData icon, Color color, String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.12),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, size: 15.r, color: color),
        ),
        SizedBox(width: 10.r),
        Text(
          title,
          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ],
    );
  }

  Widget _glassButton(IconData icon, VoidCallback onTap, {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 18.r, color: iconColor ?? Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _tinyChip(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 2.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: color),
          SizedBox(width: 3.r),
          Text(
            label,
            style: TextStyle(fontSize: 9.r, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
