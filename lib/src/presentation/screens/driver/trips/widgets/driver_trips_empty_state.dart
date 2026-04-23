import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DriverTripsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const DriverTripsEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40.r),
      child: Column(
        children: [
          Icon(
            Iconsax.car,
            size: 80.r,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
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
            style: TextStyle(
              fontSize: 14.r,
              color: isDark ? Colors.white60 : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}
