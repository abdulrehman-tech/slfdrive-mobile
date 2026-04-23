import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.r, 40.r, 20.r, 50.r),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12.r, offset: Offset(0, 4.r)),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: Colors.white,
                    child: Icon(Icons.person, size: 50.r, color: const Color(0xFF4D63DD)),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push('/profile/edit'),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8.r)],
                    ),
                    child: Icon(Iconsax.camera, size: 16.r, color: const Color(0xFF4D63DD)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Text(
            'driver_name'.tr(),
            style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          SizedBox(height: 6.r),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'driver_badge'.tr(),
              style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
