import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color_constants.dart';

/// Full-width gradient book button used in the desktop sidebar column.
class DesktopBookButton extends StatelessWidget {
  final VoidCallback onTap;

  const DesktopBookButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          child: Text(
            'car_detail_book'.tr(),
            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
