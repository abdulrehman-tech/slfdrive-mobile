import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/driver_item.dart';

class DriverListCard extends StatelessWidget {
  final DriverItem driver;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const DriverListCard({
    super.key,
    required this.driver,
    required this.isDark,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                  blurRadius: 16.r,
                  offset: Offset(0, 4.r),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatar(),
                SizedBox(width: 14.r),
                Expanded(child: _buildInfo()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CachedNetworkImage(
          imageUrl: driver.avatarUrl,
          imageBuilder: (_, img) => Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: DecorationImage(image: img, fit: BoxFit.cover),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                width: 2,
              ),
            ),
          ),
          placeholder: (_, _) => _avatarFallback(),
          errorWidget: (_, _, _) => _avatarFallback(),
        ),
        if (driver.isAvailable)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14.r,
              height: 14.r,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF1A1A2A) : Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(Iconsax.user_copy, size: 22.r, color: cs.primary.withValues(alpha: 0.4)),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                driver.name,
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!driver.isAvailable)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  'driver_status_busy'.tr(),
                  style: TextStyle(
                    fontSize: 9.r,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE53935),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.r),
        Row(
          children: [
            Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 12.r),
            SizedBox(width: 3.r),
            Text(
              '${driver.rating}',
              style: TextStyle(
                fontSize: 11.r,
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(width: 8.r),
            Icon(Iconsax.car, size: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
            SizedBox(width: 3.r),
            Text(
              '${driver.trips} trips',
              style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
            ),
            SizedBox(width: 8.r),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                driver.speciality,
                style: TextStyle(
                  fontSize: 9.r,
                  color: const Color(0xFF00BCD4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.r),
        Row(
          children: [
            Icon(Iconsax.language_circle, size: 11.r, color: cs.onSurface.withValues(alpha: 0.35)),
            SizedBox(width: 3.r),
            Expanded(
              child: Text(
                driver.languages.join(', '),
                style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.45)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OmrIcon(size: 12.r, color: cs.primary),
                SizedBox(width: 3.r),
                Text(
                  '${driver.pricePerDay.toInt()}${'driver_detail_per_day'.tr()}',
                  style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold, color: cs.primary),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
