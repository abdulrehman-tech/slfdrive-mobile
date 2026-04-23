import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/car_item.dart';
import 'glass_card.dart';
import 'spec_pill.dart';

class CarCard extends StatelessWidget {
  final CarItem car;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onFavourite;
  final VoidCallback? onTap;

  const CarCard({
    super.key,
    required this.car,
    required this.isDark,
    required this.cs,
    required this.onFavourite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        isDark: isDark,
        borderRadius: 20.r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
                  child: CachedNetworkImage(
                    imageUrl: car.imageUrl,
                    height: 150.r,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      height: 150.r,
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                      child: Center(
                        child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.4), size: 36.r),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 150.r,
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                      child: Center(
                        child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.4), size: 36.r),
                      ),
                    ),
                  ),
                ),
                if (car.tag.isNotEmpty)
                  Positioned(
                    top: 10.r,
                    left: 10.r,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(8.r)),
                      child: Text(
                        car.tag,
                        style: TextStyle(fontSize: 10.r, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10.r,
                  right: 10.r,
                  child: GestureDetector(
                    onTap: onFavourite,
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        car.isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                        color: car.isFavourite ? Colors.redAccent : (isDark ? Colors.white60 : Colors.black45),
                        size: 16.r,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10.r,
                  right: 10.r,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OmrIcon(size: 12.r, color: Colors.white),
                            SizedBox(width: 3.r),
                            Text(
                              '${car.pricePerDay.toInt()}/${'day'.tr()}',
                              style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.r),
                  Row(
                    children: [
                      SpecPill(icon: Iconsax.flash_1_copy, label: '${car.horsepower}hp', isDark: isDark, cs: cs),
                      SizedBox(width: 6.r),
                      SpecPill(icon: Iconsax.setting_copy, label: car.transmission, isDark: isDark, cs: cs),
                      SizedBox(width: 6.r),
                      SpecPill(icon: Iconsax.people_copy, label: '${car.seats}', isDark: isDark, cs: cs),
                    ],
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
