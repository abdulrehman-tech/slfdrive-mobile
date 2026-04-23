import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class StatsRow extends StatelessWidget {
  final bool isDark;
  const StatsRow({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Transform.translate(
        offset: Offset(0, -40.r),
        child: Row(
          children: [
            _StatCard(value: '245', label: 'driver_stat_trips'.tr(), icon: Iconsax.car, isDark: isDark),
            SizedBox(width: 12.r),
            _StatCard(value: '4.8', label: 'driver_stat_rating'.tr(), icon: Iconsax.star_1, isDark: isDark),
            SizedBox(width: 12.r),
            _StatCard(value: '3.2k', label: 'driver_stat_earnings'.tr(), icon: Iconsax.wallet_3, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16.r,
              offset: Offset(0, 4.r),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.r, color: const Color(0xFF4D63DD)),
            SizedBox(height: 8.r),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.r,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }
}
