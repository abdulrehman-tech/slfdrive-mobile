import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SuccessAnimatedIcon extends StatelessWidget {
  final Animation<double> tick;
  final Animation<double> pulse;
  const SuccessAnimatedIcon({super.key, required this.tick, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 130.r,
        height: 130.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: pulse,
              child: Container(
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                ),
              ),
            ),
            ScaleTransition(
              scale: pulse,
              child: Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
                ),
              ),
            ),
            ScaleTransition(
              scale: tick,
              child: Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      blurRadius: 22.r,
                      offset: Offset(0, 8.r),
                    ),
                  ],
                ),
                child: Icon(Iconsax.tick_circle_copy, size: 40.r, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
