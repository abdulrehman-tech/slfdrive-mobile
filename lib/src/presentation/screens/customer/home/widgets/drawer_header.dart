import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DrawerHeaderSection extends StatelessWidget {
  final bool isDark;

  const DrawerHeaderSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.r, 56.r, 20.r, 20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10.r,
            top: -20.r,
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          Positioned(
            right: 30.r,
            bottom: -30.r,
            child: Container(
              width: 70.r,
              height: 70.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)),
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 58.r,
                    height: 58.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.r),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: const Color(0xFF0C2485)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2.r,
                    right: 2.r,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home_greeting'.tr(),
                      style: TextStyle(fontSize: 11.r, color: Colors.white60, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 3.r),
                    Text(
                      'Guest User',
                      style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 5.r),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.medal_star_copy, color: const Color(0xFFFFC107), size: 12.r),
                          SizedBox(width: 4.r),
                          Text(
                            'drawer_guest_badge'.tr(),
                            style: TextStyle(fontSize: 9.r, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
