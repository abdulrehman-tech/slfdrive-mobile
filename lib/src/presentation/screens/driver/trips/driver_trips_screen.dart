import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  int _selectedTab = 0; // 0=Active, 1=Completed, 2=Cancelled

  final List<Map<String, dynamic>> _activeTrips = [
    {
      'id': '1',
      'customer': 'Ahmed Al-Farsi',
      'pickup': 'Muscat Grand Mall',
      'destination': 'Ruwi',
      'distance': '5.2 km',
      'fare': 12.50,
      'status': 'in_progress',
      'time': 'Started 15 min ago',
    },
  ];

  final List<Map<String, dynamic>> _completedTrips = [
    {
      'id': '101',
      'customer': 'Sarah Johnson',
      'destination': 'Al Khuwair',
      'fare': 18.00,
      'time': 'Today, 2:30 PM',
      'rating': 5.0,
    },
    {
      'id': '102',
      'customer': 'Mohammed K.',
      'destination': 'Qurum',
      'fare': 15.00,
      'time': 'Today, 12:15 PM',
      'rating': 4.5,
    },
    {
      'id': '103',
      'customer': 'Omar Saeed',
      'destination': 'Seeb',
      'fare': 22.50,
      'time': 'Yesterday, 6:45 PM',
      'rating': 5.0,
    },
    {
      'id': '104',
      'customer': 'Fatima Hassan',
      'destination': 'Al Hail',
      'fare': 18.00,
      'time': 'Yesterday, 4:20 PM',
      'rating': 4.0,
    },
  ];

  final List<Map<String, dynamic>> _cancelledTrips = [
    {
      'id': '201',
      'customer': 'Yusuf Hassan',
      'destination': 'Airport',
      'fare': 25.00,
      'time': '2 days ago',
      'reason': 'Customer cancelled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              elevation: 0,
              leadingWidth: 56.r,
              titleSpacing: 0,
              title: Text(
                'driver_trips'.tr(),
                style: TextStyle(
                  fontSize: 20.r,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              bottom: PreferredSize(preferredSize: Size.fromHeight(80.r), child: _buildTabSelector(isDark)),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.r)),
            SliverToBoxAdapter(child: _buildContent(isDark)),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 16.r),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            _buildTab('trips_active'.tr(), 0, _activeTrips.length, isDark),
            _buildTab('trips_completed'.tr(), 1, _completedTrips.length, isDark),
            _buildTab('trips_cancelled'.tr(), 2, _cancelledTrips.length, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, int count, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.r),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF1E1E1E) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r)] : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.r,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isDark
                      ? (isSelected ? Colors.white : Colors.white60)
                      : (isSelected ? Colors.black87 : const Color(0xFF757575)),
                ),
              ),
              if (count > 0) ...[
                SizedBox(height: 4.r),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 2.r),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4D63DD) : (isDark ? Colors.white24 : Colors.black26),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_selectedTab == 0) {
      return _activeTrips.isEmpty
          ? _buildEmptyState('trips_no_active'.tr(), 'trips_no_active_desc'.tr(), isDark)
          : _buildActiveTrips(isDark);
    } else if (_selectedTab == 1) {
      return _completedTrips.isEmpty
          ? _buildEmptyState('trips_no_completed'.tr(), 'trips_no_completed_desc'.tr(), isDark)
          : _buildCompletedTrips(isDark);
    } else {
      return _cancelledTrips.isEmpty
          ? _buildEmptyState('trips_no_cancelled'.tr(), 'trips_no_cancelled_desc'.tr(), isDark)
          : _buildCancelledTrips(isDark);
    }
  }

  Widget _buildEmptyState(String title, String subtitle, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(40.r),
      child: Column(
        children: [
          Icon(Iconsax.car, size: 80.r, color: isDark ? Colors.white24 : Colors.black12),
          SizedBox(height: 20.r),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTrips(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Column(children: _activeTrips.map((trip) => _buildActiveTripCard(trip, isDark)).toList()),
    );
  }

  Widget _buildActiveTripCard(Map<String, dynamic> trip, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF4D63DD).withValues(alpha: 0.3), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.r))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4D63DD)),
                    ),
                    SizedBox(width: 6.r),
                    Text(
                      'trips_in_progress'.tr(),
                      style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: const Color(0xFF4D63DD)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                trip['time'],
                style: TextStyle(fontSize: 12.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
              ),
            ],
          ),
          SizedBox(height: 16.r),
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
                      trip['customer'],
                      style: TextStyle(
                        fontSize: 15.r,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      trip['distance'],
                      style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                    ),
                  ],
                ),
              ),
              Text(
                'OMR ${trip['fare'].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)),
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
                  trip['pickup'],
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
                  trip['destination'],
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white70 : const Color(0xFF555555)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('trips_complete_snack'.tr()),
                behavior: SnackBarBehavior.floating,
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'trips_complete'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTrips(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Column(children: _completedTrips.map((trip) => _buildCompletedTripCard(trip, isDark)).toList()),
    );
  }

  Widget _buildCompletedTripCard(Map<String, dynamic> trip, bool isDark) {
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
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.tick_circle, color: const Color(0xFF4CAF50), size: 22.r),
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'To: ${trip['destination']}',
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                ),
                SizedBox(height: 4.r),
                Row(
                  children: [
                    Icon(Iconsax.star_1, size: 14.r, color: const Color(0xFFFFA000)),
                    SizedBox(width: 4.r),
                    Text(
                      trip['rating'].toString(),
                      style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: const Color(0xFFFFA000)),
                    ),
                    SizedBox(width: 8.r),
                    Text(
                      trip['time'],
                      style: TextStyle(fontSize: 12.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'OMR ${trip['fare'].toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: const Color(0xFF4D63DD)),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledTrips(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Column(children: _cancelledTrips.map((trip) => _buildCancelledTripCard(trip, isDark)).toList()),
    );
  }

  Widget _buildCancelledTripCard(Map<String, dynamic> trip, bool isDark) {
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
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.close_circle, color: Colors.red, size: 22.r),
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'To: ${trip['destination']}',
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                ),
                SizedBox(height: 4.r),
                Text(
                  trip['reason'],
                  style: TextStyle(fontSize: 12.r, color: Colors.red),
                ),
              ],
            ),
          ),
          Text(
            trip['time'],
            style: TextStyle(fontSize: 12.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
          ),
        ],
      ),
    );
  }
}
