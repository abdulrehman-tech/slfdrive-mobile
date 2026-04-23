import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'glass_card.dart';

class ServiceRow extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  const ServiceRow({super.key, this.isDesktop = false, required this.isDark});

  static const _services = [
    (Iconsax.car_copy, 'service_rent_car', Color(0xFF3D5AFE), Color(0xFFE8EAFF)),
    (Iconsax.driver_copy, 'service_car_driver', Color(0xFF7C4DFF), Color(0xFFF3EEFF)),
    (Iconsax.profile_2user_copy, 'service_hire_driver', Color(0xFF00BCD4), Color(0xFFE0F7FA)),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 0 : 16.r, 12.r, isDesktop ? 0 : 16.r, 4.r),
      child: Row(
        children: _services.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final iconColor = s.$3;
          final bgLight = s.$4;
          final bgDark = iconColor.withValues(alpha: 0.15);

          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: i < _services.length - 1 ? 10.r : 0),
              child: GestureDetector(
                onTap: () => context.pushNamed(i == 2 ? 'driver-listing' : 'car-listing'),
                child: GlassCard(
                  isDark: isDark,
                  borderRadius: 18.r,
                  padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 10.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: isDark ? bgDark : bgLight,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Icon(s.$1, color: isDark ? iconColor.withValues(alpha: 0.9) : iconColor, size: 24.r),
                      ),
                      SizedBox(height: 10.r),
                      Text(
                        s.$2.tr(),
                        style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: cs.onSurface, height: 1.3),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
