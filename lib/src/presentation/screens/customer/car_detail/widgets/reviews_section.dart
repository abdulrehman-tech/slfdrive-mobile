import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../driver_detail/widgets/review_tile.dart';
import '../provider/car_detail_provider.dart';
import 'car_glass_card.dart';
import 'section_header.dart';

/// Vehicle rating summary (average, star histogram) and review tiles. Mirrors
/// the driver detail reviews card; data comes from [CarDetailProvider].
class ReviewsSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const ReviewsSection({super.key, required this.isDark, required this.cs});

  static const _star = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarDetailProvider>();
    final rating = provider.rating ?? 0;
    final total = provider.reviewCount;
    final reviews = provider.reviews;
    final counts = provider.reviewCounts;
    final hasData = reviews.isNotEmpty || total > 0 || rating > 0;

    return CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Iconsax.message_text_copy,
              accent: _star,
              title: 'car_detail_reviews'.tr(),
              isDark: isDark,
              cs: cs,
            ),
            SizedBox(height: 14.r),
            if (!hasData)
              _empty()
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 34.r, fontWeight: FontWeight.w900, color: cs.onSurface, height: 1),
                      ),
                      SizedBox(height: 4.r),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(i < rating.round() ? Iconsax.star : Iconsax.star_copy, size: 11.r, color: _star),
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
                        final count = counts[i];
                        final histogramTotal = counts.fold<int>(0, (a, b) => a + b);
                        final frac = histogramTotal == 0 ? 0.0 : count / histogramTotal;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.5.r),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14.r,
                                child: Text(
                                  '${5 - i}',
                                  style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.7)),
                                ),
                              ),
                              Icon(Iconsax.star_1_copy, size: 10.r, color: _star),
                              SizedBox(width: 6.r),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 6.r,
                                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: frac,
                                        child: Container(
                                          height: 6.r,
                                          decoration: BoxDecoration(color: _star, borderRadius: BorderRadius.circular(4.r)),
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
              if (reviews.isNotEmpty) ...[
                SizedBox(height: 16.r),
                Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
                SizedBox(height: 12.r),
                ...reviews.asMap().entries.map(
                  (e) => ReviewTile(review: e.value, index: e.key, cs: cs, isDark: isDark),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.r),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _star.withValues(alpha: isDark ? 0.16 : 0.10)),
              child: Icon(Iconsax.star_1_copy, size: 24.r, color: _star),
            ),
            SizedBox(height: 12.r),
            Text(
              'car_detail_no_reviews'.tr(),
              style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
            ),
            SizedBox(height: 4.r),
            Text(
              'car_detail_no_reviews_sub'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
