import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/fav_car.dart';

class FavCarCard extends StatelessWidget {
  final FavCar car;
  final bool isDark;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const FavCarCard({
    super.key,
    required this.car,
    required this.isDark,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
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
              height: 120.r,
              child: Row(
                children: [
                  _buildImage(cs),
                  Expanded(child: _buildInfo(context, cs)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme cs) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(18.r),
        bottomLeft: Radius.circular(18.r),
      ),
      child: CachedNetworkImage(
        imageUrl: car.imageUrl,
        width: 120.r,
        height: 120.r,
        fit: BoxFit.cover,
        placeholder: (_, _) => _buildImagePlaceholder(cs),
        errorWidget: (_, _, _) => _buildImagePlaceholder(cs),
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme cs) {
    return Container(
      width: 120.r,
      height: 120.r,
      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(
          Iconsax.car_copy,
          color: cs.primary.withValues(alpha: 0.3),
          size: 28.r,
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.r, 10.r, 12.r, 10.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNameRow(cs),
          SizedBox(height: 6.r),
          _buildBrandRatingRow(cs),
          SizedBox(height: 10.r),
          _buildPriceBookRow(context, cs),
        ],
      ),
    );
  }

  Widget _buildNameRow(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: Text(
            car.name,
            style: TextStyle(
              fontSize: 14.r,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(Iconsax.heart_copy, color: const Color(0xFFE91E63), size: 14.r),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandRatingRow(ColorScheme cs) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 3.r),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            car.brand,
            style: TextStyle(
              fontSize: 10.r,
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
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
    );
  }

  Widget _buildPriceBookRow(BuildContext context, ColorScheme cs) {
    return Row(
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
              style: TextStyle(
                fontSize: 16.r,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.pushNamed('car-detail', pathParameters: {'id': car.id}),
          child: Container(
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
              style: TextStyle(
                fontSize: 11.r,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
