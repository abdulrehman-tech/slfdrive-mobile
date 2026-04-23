import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';

class EmptyFavorites extends StatelessWidget {
  final bool isDark;

  const EmptyFavorites({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.heart,
              color: const Color(0xFFE91E63).withValues(alpha: 0.6),
              size: 40.r,
            ),
          ),
          SizedBox(height: 20.r),
          Text(
            'favorites_empty_title'.tr(),
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: 8.r),
          SizedBox(
            width: 260.r,
            child: Text(
              'favorites_empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.r,
                color: cs.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24.r),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 12.r),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.r),
                  ),
                ],
              ),
              child: Text(
                'favorites_explore'.tr(),
                style: TextStyle(
                  fontSize: 14.r,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
