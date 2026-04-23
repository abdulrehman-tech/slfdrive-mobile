import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/driver_home_provider.dart';

class QuickStatsRow extends StatelessWidget {
  final bool isDark;

  const QuickStatsRow({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverHomeProvider>();

    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          _StatCard(
            icon: Iconsax.car,
            value: provider.totalTrips.toString(),
            label: 'driver_trips'.tr(),
            color: const Color(0xFF4D63DD),
            isDark: isDark,
          ),
          SizedBox(width: 12.r),
          _StatCard(
            icon: Iconsax.star_1,
            value: provider.rating.toString(),
            label: 'driver_rating'.tr(),
            color: const Color(0xFFFFA000),
            isDark: isDark,
          ),
          SizedBox(width: 12.r),
          _StatCard(
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
}
