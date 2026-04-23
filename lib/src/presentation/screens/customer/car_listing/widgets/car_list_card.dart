import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/car_item.dart';
import 'spec_chip.dart';

/// Horizontal glass card rendering a single car row with image + specs + CTA.
class CarListCard extends StatelessWidget {
  final CarItem car;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const CarListCard({
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
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
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
            child: SizedBox(
              height: 140.r,
              child: Row(
                children: [
                  _buildImage(),
                  Expanded(child: _buildInfo()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            bottomLeft: Radius.circular(18.r),
          ),
          child: CachedNetworkImage(
            imageUrl: car.imageUrl,
            width: 130.r,
            height: 140.r,
            fit: BoxFit.cover,
            placeholder: (_, _) => _imageFallback(),
            errorWidget: (_, _, _) => _imageFallback(),
          ),
        ),
        if (!car.isAvailable)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                bottomLeft: Radius.circular(18.r),
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Unavailable',
                      style: TextStyle(fontSize: 9.r, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 130.r,
      height: 140.r,
      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.3), size: 28.r),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.r, 12.r, 12.r, 12.r),
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
                padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 3.r),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  car.brand,
                  style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 8.r),
              Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 12.r),
              SizedBox(width: 3.r),
              Text(
                car.rating.toString(),
                style: TextStyle(
                  fontSize: 11.r,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          Row(
            children: [
              SpecChip(icon: Iconsax.people, label: '${car.seats}', isDark: isDark, cs: cs),
              SizedBox(width: 6.r),
              SpecChip(icon: Iconsax.cpu_setting, label: car.transmission, isDark: isDark, cs: cs),
              SizedBox(width: 6.r),
              SpecChip(icon: Iconsax.gas_station, label: car.fuelType, isDark: isDark, cs: cs),
            ],
          ),
          SizedBox(height: 10.r),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OmrIcon(size: 13.r, color: cs.primary),
                  SizedBox(width: 3.r),
                  Text(
                    '${car.pricePerDay.toInt()}/${'day'.tr()}',
                    style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.primary),
                  ),
                ],
              ),
              if (car.isAvailable)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 7.r),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(9.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C2485).withValues(alpha: 0.25),
                        blurRadius: 8.r,
                        offset: Offset(0, 3.r),
                      ),
                    ],
                  ),
                  child: Text(
                    'book_now'.tr(),
                    style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
