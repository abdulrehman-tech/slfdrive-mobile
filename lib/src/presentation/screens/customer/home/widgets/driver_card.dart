import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_item.dart';
import 'glass_card.dart';

class DriverCard extends StatelessWidget {
  final DriverItem driver;
  final bool isDark;
  final ColorScheme cs;
  final bool horizontal;
  final VoidCallback? onTap;

  const DriverCard({
    super.key,
    required this.driver,
    required this.isDark,
    required this.cs,
    this.horizontal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return horizontal ? _buildHorizontal() : _buildVertical();
  }

  Widget _buildVertical() {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        isDark: isDark,
        borderRadius: 18,
        padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: 10.r),
        child: SizedBox(
          width: 110.r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _avatar(28.r),
                  Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF1A1A2A) : Colors.white, width: 1.5),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.r),
              Text(
                driver.name.split(' ').first,
                style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3.r),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  driver.speciality,
                  style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 4.r),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 11.r),
                  SizedBox(width: 2.r),
                  Text(
                    driver.rating.toString(),
                    style: TextStyle(
                      fontSize: 11.r,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontal() {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        isDark: isDark,
        borderRadius: 14,
        padding: EdgeInsets.all(12.r),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                _avatar(24.r),
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? const Color(0xFF1A1A2A) : Colors.white, width: 1.5),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.r),
                  Row(
                    children: [
                      Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 11.r),
                      SizedBox(width: 2.r),
                      Text(
                        '${driver.rating}  ·  ${driver.trips} trips',
                        style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Text(
                'available'.tr(),
                style: TextStyle(fontSize: 10.r, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(double radius) {
    return CachedNetworkImage(
      imageUrl: driver.avatarUrl,
      imageBuilder: (_, img) => CircleAvatar(radius: radius, backgroundImage: img),
      placeholder: (_, _) => CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
        child: Icon(Iconsax.user_copy, size: radius * 0.8, color: cs.primary.withValues(alpha: 0.5)),
      ),
      errorWidget: (_, _, _) => CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
        child: Icon(Iconsax.user_copy, size: radius * 0.8, color: cs.primary.withValues(alpha: 0.5)),
      ),
    );
  }
}
