import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/search_result_car.dart';

class SearchCarCard extends StatelessWidget {
  final SearchResultCar car;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const SearchCarCard({
    super.key,
    required this.car,
    required this.isDark,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: SizedBox(
              height: 120.r,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: car.imageUrl,
                      width: 120.r,
                      height: 120.r,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _imgFallback(),
                      errorWidget: (_, _, _) => _imgFallback(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            car.name,
                            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.r),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Text(
                                  car.brand,
                                  style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(width: 6.r),
                              Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 11.r),
                              SizedBox(width: 2.r),
                              Text(
                                car.rating.toString(),
                                style: TextStyle(
                                  fontSize: 10.r,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.r),
                          Row(
                            children: [
                              _specChip(Iconsax.people_copy, '${car.seats}', cs),
                              SizedBox(width: 6.r),
                              _specChip(Iconsax.cpu_setting, car.transmission, cs),
                            ],
                          ),
                          SizedBox(height: 6.r),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OmrIcon(size: 12.r, color: cs.primary),
                              SizedBox(width: 3.r),
                              Text(
                                '${car.pricePerDay.toInt()}/${'day'.tr()}',
                                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 120.r,
        height: 120.r,
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
        child: Center(child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.3), size: 28.r)),
      );

  Widget _specChip(IconData icon, String label, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: cs.onSurface.withValues(alpha: 0.4)),
          SizedBox(width: 3.r),
          Text(
            label,
            style: TextStyle(fontSize: 9.r, color: cs.onSurface.withValues(alpha: 0.55), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
