import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/driver_home_provider.dart';

class DriverHeader extends StatelessWidget {
  final bool isDark;

  const DriverHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverHomeProvider>();
    final isOnline = provider.isOnline;

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
            onTap: () => context.read<DriverHomeProvider>().toggleOnline(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
              decoration: BoxDecoration(
                gradient: isOnline ? const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]) : null,
                color: isOnline ? null : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[300]),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: isOnline ? Colors.green : Colors.red),
                  ),
                  SizedBox(width: 8.r),
                  Text(
                    isOnline ? 'driver_online'.tr() : 'driver_offline'.tr(),
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: FontWeight.w600,
                      color: isOnline ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
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
}
