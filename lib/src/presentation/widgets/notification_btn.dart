import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NotificationBtn extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;
  const NotificationBtn({super.key, required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed('notifications'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
              ),
            ),
            child: Icon(Iconsax.notification_copy, color: cs.onSurface.withValues(alpha: 0.7), size: 18.r),
          ),
          Positioned(
            top: -1.r,
            right: -1.r,
            child: Container(
              width: 9.r,
              height: 9.r,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF0F0F18) : Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
