import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Decorative gradient banner rendered in the desktop layout only.
/// Mobile layout uses [MobileGreeting] instead.
class HeroBanner extends StatelessWidget {
  final bool isDark;
  final Animation<double> fade;

  const HeroBanner({super.key, required this.isDark, required this.fade});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: fade,
      child: Container(
        height: 200.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A237E), const Color(0xFF4A148C)]
                : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.3 : 0.25),
              blurRadius: 24.r,
              offset: Offset(0, 8.r),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30.r,
              top: -30.r,
              child: Container(
                width: 160.r,
                height: 160.r,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            Positioned(
              right: 60.r,
              bottom: -40.r,
              child: Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 3.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF69FF47)),
                        ),
                        SizedBox(width: 5.r),
                        Text(
                          'home_available_now'.tr(),
                          style: TextStyle(color: Colors.white, fontSize: 10.r, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    'home_greeting'.tr(),
                    style: TextStyle(fontSize: 14.r, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 3.r),
                  Text(
                    'home_headline'.tr(),
                    style: TextStyle(
                      fontSize: 20.r,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
