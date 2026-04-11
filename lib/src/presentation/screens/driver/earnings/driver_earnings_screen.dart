import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  int _selectedPeriod = 0; // 0=Today, 1=Week, 2=Month, 3=Year

  final Map<String, dynamic> _todayData = {'total': 145.50, 'trips': 12, 'hours': 8.5, 'avgPerTrip': 12.13};

  final Map<String, dynamic> _weekData = {'total': 890.00, 'trips': 68, 'hours': 52.0, 'avgPerTrip': 13.09};

  final Map<String, dynamic> _monthData = {'total': 3420.00, 'trips': 245, 'hours': 198.0, 'avgPerTrip': 13.96};

  final List<Map<String, dynamic>> _recentEarnings = [
    {'date': 'Today, 2:30 PM', 'customer': 'Ahmed Al-Farsi', 'amount': 18.50, 'status': 'completed'},
    {'date': 'Today, 12:15 PM', 'customer': 'Sarah Johnson', 'amount': 22.00, 'status': 'completed'},
    {'date': 'Today, 10:00 AM', 'customer': 'Omar Saeed', 'amount': 15.00, 'status': 'completed'},
    {'date': 'Yesterday, 6:45 PM', 'customer': 'Fatima Hassan', 'amount': 28.00, 'status': 'completed'},
    {'date': 'Yesterday, 4:20 PM', 'customer': 'Mohammed K.', 'amount': 12.50, 'status': 'completed'},
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
                'driver_earnings'.tr(),
                style: TextStyle(
                  fontSize: 20.r,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              bottom: PreferredSize(preferredSize: Size.fromHeight(72.r), child: _buildPeriodSelector(isDark)),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.r)),
            SliverToBoxAdapter(child: _buildEarningsCard(isDark)),
            SliverToBoxAdapter(child: SizedBox(height: 20.r)),
            SliverToBoxAdapter(child: _buildStatsGrid(isDark)),
            SliverToBoxAdapter(child: _buildRecentEarnings(isDark)),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
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
            _buildPeriodTab('earnings_today'.tr(), 0, isDark),
            _buildPeriodTab('earnings_week'.tr(), 1, isDark),
            _buildPeriodTab('earnings_month'.tr(), 2, isDark),
            _buildPeriodTab('earnings_year'.tr(), 3, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index, bool isDark) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.r),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF1E1E1E) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r)] : null,
          ),
          child: Text(
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
        ),
      ),
    );
  }

  Widget _buildEarningsCard(bool isDark) {
    final data = _selectedPeriod == 0
        ? _todayData
        : _selectedPeriod == 1
        ? _weekData
        : _monthData;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        padding: EdgeInsets.all(24.r),
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
                  'earnings_total'.tr(),
                  style: TextStyle(fontSize: 14.r, color: Colors.white.withValues(alpha: 0.8)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.arrow_up, size: 14.r, color: Colors.white),
                      SizedBox(width: 4.r),
                      Text(
                        '+12%',
                        style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Text(
              'OMR ${data['total'].toStringAsFixed(2)}',
              style: TextStyle(fontSize: 36.r, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8.r),
            Text(
              '${data['trips']} trips • ${data['hours']} hours',
              style: TextStyle(fontSize: 14.r, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    final data = _selectedPeriod == 0
        ? _todayData
        : _selectedPeriod == 1
        ? _weekData
        : _monthData;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.car,
                  label: 'earnings_trips'.tr(),
                  value: data['trips'].toString(),
                  color: const Color(0xFF4D63DD),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.clock,
                  label: 'earnings_hours'.tr(),
                  value: data['hours'].toString(),
                  color: const Color(0xFFFFA000),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.r),
          _buildStatCard(
            icon: Iconsax.chart,
            label: 'earnings_avg_trip'.tr(),
            value: 'OMR ${data['avgPerTrip'].toStringAsFixed(2)}',
            color: const Color(0xFF4CAF50),
            isDark: isDark,
            isWide: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    bool isWide = false,
  }) {
    return Container(
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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: color, size: 24.r),
          ),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                ),
                SizedBox(height: 4.r),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.r,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEarnings(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'earnings_recent'.tr(),
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.r),
          ..._recentEarnings.map((earning) => _buildEarningCard(earning, isDark)),
        ],
      ),
    );
  }

  Widget _buildEarningCard(Map<String, dynamic> earning, bool isDark) {
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
                  earning['customer'],
                  style: TextStyle(
                    fontSize: 15.r,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  earning['date'],
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                ),
              ],
            ),
          ),
          Text(
            'OMR ${earning['amount'].toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: const Color(0xFF4D63DD)),
          ),
        ],
      ),
    );
  }
}
