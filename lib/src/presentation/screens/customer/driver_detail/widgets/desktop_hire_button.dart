import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/driver_profile.dart';

class DesktopHireButton extends StatelessWidget {
  final DriverProfile profile;
  final ColorScheme cs;
  final VoidCallback onTap;

  const DesktopHireButton({super.key, required this.profile, required this.cs, required this.onTap});

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
              Text('·', style: TextStyle(fontSize: 15.r, color: Colors.white54)),
              SizedBox(width: 8.r),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OmrIcon(size: 11.r, color: Colors.white70),
                  SizedBox(width: 3.r),
                  Text(
                    '${profile.dailyRate.toInt()}/${'day'.tr()}',
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
}
