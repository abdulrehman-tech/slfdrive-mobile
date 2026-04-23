import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_profile.dart';
import 'glass_card.dart';
import 'tiny_chip.dart';

class IdentityCard extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;

  const IdentityCard({super.key, required this.profile, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return DriverGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary.withValues(alpha: 0.4), width: 3),
                    boxShadow: [
                      BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 14.r, offset: Offset(0, 5.r)),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profile.avatarUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFEEEEEE),
                        child: Icon(Iconsax.user_copy, size: 30.r, color: cs.primary),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 2.r,
                  bottom: 2.r,
                  child: Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF1A1A28) : Colors.white, width: 2.5),
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.name,
                          style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.r),
                      Icon(Iconsax.verify_copy, size: 16.r, color: cs.primary),
                    ],
                  ),
                  SizedBox(height: 6.r),
                  Wrap(
                    spacing: 6.r,
                    runSpacing: 4.r,
                    children: [
                      TinyChip(
                        icon: Iconsax.tick_circle_copy,
                        label: 'driver_detail_verified_id'.tr(),
                        color: const Color(0xFF4CAF50),
                        isDark: isDark,
                      ),
                      TinyChip(
                        icon: Iconsax.driver_copy,
                        label: 'driver_detail_verified_license'.tr(),
                        color: const Color(0xFF3D5AFE),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 5.r),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  ),
                  SizedBox(width: 5.r),
                  Text(
                    'driver_detail_available'.tr(),
                    style: TextStyle(fontSize: 10.r, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w800),
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
