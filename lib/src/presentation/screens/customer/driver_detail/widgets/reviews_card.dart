import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../common/coming_soon_screen.dart';
import '../models/driver_profile.dart';
import 'glass_card.dart';
import 'review_tile.dart';
import 'section_header.dart';

class ReviewsCard extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;

  const ReviewsCard({super.key, required this.profile, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final total = profile.totalReviews;
    return DriverGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DriverSectionHeader(
              cs: cs,
              icon: Iconsax.message_text_copy,
              color: const Color(0xFFFFC107),
              title: 'driver_detail_reviews'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 14.r),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '${profile.rating}',
                      style: TextStyle(fontSize: 34.r, fontWeight: FontWeight.w900, color: cs.onSurface, height: 1),
                    ),
                    SizedBox(height: 4.r),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < profile.rating.round() ? Iconsax.star_1_copy : Iconsax.star_1,
                          size: 11.r,
                          color: const Color(0xFFFFC107),
                        ),
                      ),
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      '$total ${'driver_detail_reviews_count'.tr()}',
                      style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
                SizedBox(width: 20.r),
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count = profile.reviewCounts[i];
                      final frac = total == 0 ? 0.0 : count / total;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.5.r),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14.r,
                              child: Text(
                                '$star',
                                style: TextStyle(
                                  fontSize: 10.r,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            Icon(Iconsax.star_1_copy, size: 10.r, color: const Color(0xFFFFC107)),
                            SizedBox(width: 6.r),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 6.r,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(alpha: 0.05),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: frac,
                                      child: Container(
                                        height: 6.r,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFC107),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.r),
                            SizedBox(
                              width: 30.r,
                              child: Text(
                                '$count',
                                style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.r),
            Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
            ),
            SizedBox(height: 12.r),
            ...profile.reviews.asMap().entries.map(
                  (e) => ReviewTile(review: e.value, index: e.key, cs: cs, isDark: isDark),
                ),
            SizedBox(height: 6.r),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ComingSoonScreen(titleKey: 'driver_detail_view_all_reviews'),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 10.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Text(
                    'driver_detail_view_all_reviews'.tr(),
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w800, color: cs.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
