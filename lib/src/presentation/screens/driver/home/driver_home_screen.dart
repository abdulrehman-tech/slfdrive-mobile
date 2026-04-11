import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import '../earnings/driver_earnings_screen.dart';
import '../profile/driver_profile_screen.dart';
import '../trips/driver_trips_screen.dart';

// ============================================================
// MOCK DATA
// ============================================================

class _TripRequest {
  final String id;
  final String customer;
  final String pickup;
  final String destination;
  final String distance;
  final double fare;
  final String time;
  const _TripRequest(this.id, this.customer, this.pickup, this.destination, this.distance, this.fare, this.time);
}

final List<_TripRequest> _mockRequests = [
  _TripRequest('1', 'Ahmed Al-Farsi', 'Muscat Grand Mall', 'Ruwi', '5.2 km', 12.50, '2 min'),
  _TripRequest('2', 'Sarah Johnson', 'Airport Terminal 1', 'Al Khuwair', '8.5 km', 18.00, '5 min'),
];

// ============================================================
// LOGOUT DIALOG HELPER
// ============================================================

void _showDriverLogoutDialog(BuildContext context, bool isDark) {
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
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.logout, color: const Color(0xFFE53935), size: 32.r),
                ),
                SizedBox(height: 20.r),
                Text(
                  'driver_logout_title'.tr(),
                  style: TextStyle(
                    fontSize: 20.r,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.r),
                Text(
                  'driver_logout_message'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.r, color: isDark ? Colors.white70 : Colors.black54, height: 1.4),
                ),
                SizedBox(height: 24.r),
                Row(
                  children: [
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
                          'driver_logout_cancel'.tr(),
                          style: TextStyle(
                            fontSize: 15.r,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.r),
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
                          'driver_logout_confirm'.tr(),
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
// DRIVER HOME SCREEN
// ============================================================

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  final double _todayEarnings = 145.50;
  final int _totalTrips = 12;
  final double _rating = 4.8;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= Breakpoints.desktop;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      drawer: isDesktop ? null : _buildDrawer(isDark),
      body: SafeArea(child: isDesktop ? _buildDesktopLayout(isDark) : _buildMobileLayout(isDark)),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(isDark),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return _buildScreenBody(isDark, false);
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        _buildDesktopDrawer(isDark),
        Expanded(child: _buildScreenBody(isDark, true)),
      ],
    );
  }

  Widget _buildScreenBody(bool isDark, bool isDesktop) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(isDark, isDesktop);
      case 1:
        return const DriverEarningsScreen();
      case 2:
        return const DriverTripsScreen();
      case 3:
        return const DriverProfileScreen();
      default:
        return _buildHomeContent(isDark, isDesktop);
    }
  }

  Widget _buildHomeContent(bool isDark, bool isDesktop) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(isDark)),
        SliverToBoxAdapter(child: _buildEarningsCard(isDark)),
        SliverToBoxAdapter(child: _buildQuickStats(isDark)),
        SliverToBoxAdapter(child: _buildTripRequests(isDark)),
        SliverToBoxAdapter(child: SizedBox(height: 100.r)),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.menu, size: 20.r, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'driver_welcome'.tr(),
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                ),
                SizedBox(height: 2.r),
                Text(
                  'driver_name'.tr(),
                  style: TextStyle(
                    fontSize: 18.r,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isOnline = !_isOnline),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
              decoration: BoxDecoration(
                gradient: _isOnline ? const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]) : null,
                color: _isOnline ? null : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[300]),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _isOnline ? Colors.green : Colors.red),
                  ),
                  SizedBox(width: 8.r),
                  Text(
                    _isOnline ? 'driver_online'.tr() : 'driver_offline'.tr(),
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: FontWeight.w600,
                      color: _isOnline ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4D63DD).withValues(alpha: 0.3), blurRadius: 20.r, offset: Offset(0, 8.r)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'driver_today_earnings'.tr(),
                  style: TextStyle(fontSize: 14.r, color: Colors.white.withValues(alpha: 0.8)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '+12%',
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Text(
              'OMR ${_todayEarnings.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 32.r, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20.r),
            Row(
              children: [
                _buildBar('Mon', 0.6, isDark),
                _buildBar('Tue', 0.8, isDark),
                _buildBar('Wed', 0.4, isDark),
                _buildBar('Thu', 0.9, isDark),
                _buildBar('Fri', 0.7, isDark),
                _buildBar('Sat', 0.5, isDark),
                _buildBar('Sun', 1.0, isDark, isToday: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String day, double height, bool isDark, {bool isToday = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40.r * height,
            decoration: BoxDecoration(
              color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            day,
            style: TextStyle(
              fontSize: 10.r,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          _buildStatCard(
            icon: Iconsax.car,
            value: _totalTrips.toString(),
            label: 'driver_trips'.tr(),
            color: const Color(0xFF4D63DD),
            isDark: isDark,
          ),
          SizedBox(width: 12.r),
          _buildStatCard(
            icon: Iconsax.star_1,
            value: _rating.toString(),
            label: 'driver_rating'.tr(),
            color: const Color(0xFFFFA000),
            isDark: isDark,
          ),
          SizedBox(width: 12.r),
          _buildStatCard(
            icon: Iconsax.tick_circle,
            value: '96%',
            label: 'driver_completion'.tr(),
            color: const Color(0xFF4CAF50),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.r))],
        ),
        child: Column(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: color, size: 20.r),
            ),
            SizedBox(height: 12.r),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.r,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              label,
              style: TextStyle(fontSize: 12.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripRequests(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'driver_new_requests'.tr(),
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.r),
          ..._mockRequests.map((trip) => _buildTripRequestCard(trip, isDark)),
        ],
      ),
    );
  }

  Widget _buildTripRequestCard(_TripRequest trip, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.r))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.user, color: const Color(0xFF4D63DD), size: 20.r),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.customer,
                      style: TextStyle(
                        fontSize: 15.r,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      '${trip.distance} • ${trip.time} away',
                      style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'OMR ${trip.fare.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Row(
            children: [
              Icon(Iconsax.location, size: 16.r, color: const Color(0xFF4D63DD)),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  trip.pickup,
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white70 : const Color(0xFF555555)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          Row(
            children: [
              Icon(Iconsax.location_tick, size: 16.r, color: const Color(0xFF4CAF50)),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  trip.destination,
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white70 : const Color(0xFF555555)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'driver_decline'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'driver_accept'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20.r, offset: Offset(0, -4.r))],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 12.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Iconsax.home_2, 'driver_home'.tr(), 0, isDark),
              _buildNavItem(Iconsax.wallet_3, 'driver_earnings'.tr(), 1, isDark),
              _buildNavItem(Iconsax.car, 'driver_trips'.tr(), 2, isDark),
              _buildNavItem(Iconsax.user, 'driver_profile'.tr(), 3, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24.r, color: isActive ? const Color(0xFF4D63DD) : Colors.grey),
          SizedBox(height: 4.r),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.r,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? const Color(0xFF4D63DD) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(isDark, cs),
            Expanded(child: _buildDrawerItems(isDark, borderCol)),
            _buildDrawerBottom(isDark, cs, borderCol),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopDrawer(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    return Container(
      width: 280.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
        border: Border(right: BorderSide(color: borderCol)),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(isDark, cs),
          Expanded(child: _buildDrawerItems(isDark, borderCol)),
          _buildDrawerBottom(isDark, cs, borderCol),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4D63DD).withValues(alpha: 0.6),
                  const Color(0xFF0C2485).withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(3.r),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ),
                child: Icon(Icons.person, size: 40.r, color: const Color(0xFF4D63DD)),
              ),
            ),
          ),
          SizedBox(height: 12.r),
          Text(
            'driver_name'.tr(),
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4.r),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 4.r),
            decoration: BoxDecoration(
              color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'driver_badge'.tr(),
              style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: const Color(0xFF4D63DD)),
            ),
          ),
          SizedBox(height: 16.r),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip('$_totalTrips', 'driver_trips'.tr(), isDark),
              _buildStatChip(_rating.toString(), 'driver_rating'.tr(), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87),
        ),
        SizedBox(height: 2.r),
        Text(
          label,
          style: TextStyle(fontSize: 11.r, color: isDark ? Colors.white60 : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDrawerItems(bool isDark, Color borderCol) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.r),
      children: [
        _buildDrawerItem(Iconsax.home_2, 'driver_home'.tr(), 0, isDark),
        _buildDrawerItem(Iconsax.wallet_3, 'driver_earnings'.tr(), 1, isDark),
        _buildDrawerItem(Iconsax.car, 'driver_trips'.tr(), 2, isDark),
        _buildDrawerItem(Iconsax.user, 'driver_profile'.tr(), 3, isDark),
        Divider(height: 32.r, color: borderCol),
        _buildDrawerItem(Iconsax.setting_2, 'driver_settings'.tr(), 4, isDark),
        _buildDrawerItem(Iconsax.message_question, 'driver_help'.tr(), 5, isDark),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, bool isDark) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4.r),
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? const Color(0xFF4D63DD).withValues(alpha: 0.15)
                    : const Color(0xFF4D63DD).withValues(alpha: 0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.r,
              color: isSelected ? const Color(0xFF4D63DD) : (isDark ? Colors.white70 : Colors.black54),
            ),
            SizedBox(width: 16.r),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.r,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF4D63DD) : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerBottom(bool isDark, ColorScheme cs, Color borderCol) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 28.r),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderCol)),
      ),
      child: Column(
        children: [
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
                  isActive: !context.watch<ThemeProvider>().isDarkMode && !context.watch<ThemeProvider>().isSystemMode,
                  activeColor: const Color(0xFFFFA000),
                  onTap: () => context.read<ThemeProvider>().setLightMode(),
                  isDark: isDark,
                ),
                _ThemePill(
                  label: 'theme_dark'.tr(),
                  icon: Iconsax.moon,
                  isActive: context.watch<ThemeProvider>().isDarkMode,
                  activeColor: const Color(0xFF7C4DFF),
                  onTap: () => context.read<ThemeProvider>().setDarkMode(),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.r),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              _showDriverLogoutDialog(context, isDark);
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
                    'driver_sign_out'.tr(),
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
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemePill({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.r),
          decoration: BoxDecoration(
            color: isActive ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isActive
                ? [BoxShadow(color: activeColor.withValues(alpha: 0.2), blurRadius: 8.r, offset: Offset(0, 2.r))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.r, color: isActive ? activeColor : (isDark ? Colors.white54 : Colors.black38)),
              SizedBox(width: 6.r),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.r,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : (isDark ? Colors.white54 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
