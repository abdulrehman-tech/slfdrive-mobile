import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

const Color _secondaryColor = Color(0xFF4D63DD);

/// Beautiful driver dashboard with earnings, trips, ratings, and trip requests.
class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  int _selectedTab = 0;
  late AnimationController _animationController;

  // Mock data
  final double _todayEarnings = 145.50;
  final int _totalTrips = 12;
  final double _rating = 4.8;
  final int _completionRate = 96;

  final List<Map<String, dynamic>> _tripRequests = [
    {
      'id': '1',
      'customer': 'Ahmed Al-Farsi',
      'pickup': 'Muscat Grand Mall',
      'destination': 'Ruwi',
      'distance': '5.2 km',
      'fare': 12.50,
      'time': '2 min',
    },
    {
      'id': '2',
      'customer': 'Sarah Johnson',
      'pickup': 'Airport Terminal 1',
      'destination': 'Al Khuwair',
      'distance': '8.5 km',
      'fare': 18.00,
      'time': '5 min',
    },
  ];

  final List<Map<String, dynamic>> _recentTrips = [
    {
      'id': '101',
      'customer': 'Mohammed K.',
      'destination': 'Qurum',
      'fare': 15.00,
      'status': 'completed',
      'time': '10:30 AM',
    },
    {
      'id': '102',
      'customer': 'Yusuf Hassan',
      'destination': 'Seeb',
      'fare': 22.50,
      'status': 'completed',
      'time': '9:15 AM',
    },
    {
      'id': '103',
      'customer': 'Omar Saeed',
      'destination': 'Al Hail',
      'fare': 18.00,
      'status': 'cancelled',
      'time': '8:45 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader(isDark)),

            // Earnings Card
            SliverToBoxAdapter(child: _buildEarningsCard(isDark)),

            // Quick Stats
            SliverToBoxAdapter(child: _buildQuickStats(isDark)),

            // Tab Switcher
            SliverToBoxAdapter(child: _buildTabSwitcher(isDark)),

            // Content based on selected tab
            SliverToBoxAdapter(child: _selectedTab == 0 ? _buildTripRequests(isDark) : _buildRecentTrips(isDark)),

            // Bottom padding
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_secondaryColor.withValues(alpha: 0.6), const Color(0xFF0C2485).withValues(alpha: 0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ),
                child: Icon(Icons.person, size: 28.r, color: _secondaryColor),
              ),
            ),
          ),
          SizedBox(width: 16.r),

          // Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                ),
                SizedBox(height: 2.r),
                Text(
                  'Driver Name',
                  style: TextStyle(
                    fontSize: 18.r,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                  ),
                ),
              ],
            ),
          ),

          // Online/Offline Toggle
          GestureDetector(
            onTap: () {
              setState(() => _isOnline = !_isOnline);
            },
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
                    _isOnline ? 'Online' : 'Offline',
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
            BoxShadow(color: _secondaryColor.withValues(alpha: 0.3), blurRadius: 20.r, offset: Offset(0, 8.r)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Earnings",
                  style: TextStyle(fontSize: 14.r, color: Colors.white.withValues(alpha: 0.8)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '+12% vs yesterday',
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
            // Simple bar chart
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
            icon: Iconsax.car_copy,
            value: _totalTrips.toString(),
            label: 'Trips',
            color: const Color(0xFF4D63DD),
            isDark: isDark,
          ),
          SizedBox(width: 12.r),
          _buildStatCard(
            icon: Iconsax.star_1_copy,
            value: _rating.toString(),
            label: 'Rating',
            color: const Color(0xFFFFA000),
            isDark: isDark,
          ),
          SizedBox(width: 12.r),
          _buildStatCard(
            icon: Iconsax.tick_circle_copy,
            value: '${_completionRate}%',
            label: 'Completion',
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
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
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

  Widget _buildTabSwitcher(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 12.r),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0 ? (isDark ? const Color(0xFF2A2A2A) : Colors.white) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: _selectedTab == 0
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r)]
                        : null,
                  ),
                  child: Text(
                    'Trip Requests',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: _selectedTab == 0 ? FontWeight.w600 : FontWeight.w500,
                      color: isDark
                          ? (_selectedTab == 0 ? Colors.white : Colors.white60)
                          : (_selectedTab == 0 ? const Color(0xFF3D3D3D) : const Color(0xFF757575)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 12.r),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1 ? (isDark ? const Color(0xFF2A2A2A) : Colors.white) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: _selectedTab == 1
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r)]
                        : null,
                  ),
                  child: Text(
                    'Recent Trips',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: _selectedTab == 1 ? FontWeight.w600 : FontWeight.w500,
                      color: isDark
                          ? (_selectedTab == 1 ? Colors.white : Colors.white60)
                          : (_selectedTab == 1 ? const Color(0xFF3D3D3D) : const Color(0xFF757575)),
                    ),
                  ),
                ),
              ),
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
            '${_tripRequests.length} New Requests',
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
          ),
          SizedBox(height: 16.r),
          ..._tripRequests.map((trip) => _buildTripRequestCard(trip, isDark)),
        ],
      ),
    );
  }

  Widget _buildTripRequestCard(Map<String, dynamic> trip, bool isDark) {
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
                  color: _secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.user_copy, color: _secondaryColor, size: 20.r),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip['customer'],
                      style: TextStyle(
                        fontSize: 15.r,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                      ),
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      '${trip['distance']} • ${trip['time']} away',
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
                  'OMR ${trip['fare'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Row(
            children: [
              Icon(Iconsax.location_copy, size: 16.r, color: _secondaryColor),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  trip['pickup'],
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white70 : const Color(0xFF555555)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          Row(
            children: [
              Icon(Iconsax.location_tick_copy, size: 16.r, color: const Color(0xFF4CAF50)),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  trip['destination'],
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
                  onTap: () {
                    // Decline trip
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Decline',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Accept trip
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Accept',
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

  Widget _buildRecentTrips(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last ${_recentTrips.length} Trips',
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
          ),
          SizedBox(height: 16.r),
          ..._recentTrips.map((trip) => _buildRecentTripCard(trip, isDark)),
        ],
      ),
    );
  }

  Widget _buildRecentTripCard(Map<String, dynamic> trip, bool isDark) {
    final isCompleted = trip['status'] == 'completed';
    final statusColor = isCompleted ? const Color(0xFF4CAF50) : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.r))],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isCompleted ? Iconsax.tick_circle_copy : Iconsax.close_circle_copy,
              color: statusColor,
              size: 22.r,
            ),
          ),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['customer'],
                  style: TextStyle(
                    fontSize: 15.r,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'To: ${trip['destination']}',
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'OMR ${trip['fare'].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: _secondaryColor),
              ),
              SizedBox(height: 4.r),
              Text(
                trip['time'],
                style: TextStyle(fontSize: 12.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
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
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Iconsax.home_2_copy, 'Home', true),
                  _buildNavItem(Iconsax.wallet_3_copy, 'Earnings', false),
                  _buildNavItem(Iconsax.user_copy, 'Profile', false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24.r, color: isActive ? _secondaryColor : Colors.grey),
        SizedBox(height: 4.r),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.r,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? _secondaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
