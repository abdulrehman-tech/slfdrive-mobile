import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/search_result_driver.dart';

class SearchDriverCard extends StatelessWidget {
  final SearchResultDriver driver;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const SearchDriverCard({
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
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CachedNetworkImage(
                      imageUrl: driver.avatarUrl,
                      imageBuilder: (_, img) => CircleAvatar(radius: 24.r, backgroundImage: img),
                      placeholder: (_, _) => CircleAvatar(
                        radius: 24.r,
                        backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                      ),
                      errorWidget: (_, _, _) => CircleAvatar(
                        radius: 24.r,
                        backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                      ),
                    ),
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
                        style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.r),
                      Row(
                        children: [
                          Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 11.r),
                          SizedBox(width: 2.r),
                          Text(
                            '${driver.rating}',
                            style: TextStyle(
                              fontSize: 10.r,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(width: 6.r),
                          Text('·', style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.3))),
                          SizedBox(width: 6.r),
                          Text(
                            '${driver.trips} trips',
                            style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        driver.speciality,
                        style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 6.r),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OmrIcon(size: 10.r, color: cs.primary),
                        SizedBox(width: 2.r),
                        Text(
                          '${driver.pricePerDay.toInt()}/${'day'.tr()}',
                          style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.bold, color: cs.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
