import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/review/review.dart';
import 'glass_card.dart';
import 'section_header.dart';

/// Read-only card showing the review the customer already left for this
/// booking — replaces the "leave a review" action (one review per booking).
class MyReviewCard extends StatelessWidget {
  final Review review;
  final bool isDark;
  final ColorScheme cs;

  const MyReviewCard({super.key, required this.review, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    const star = Color(0xFFFFC107);
    final comment = (review.comment ?? '').trim();
    final created = DateTime.tryParse(review.createdAt ?? '')?.toLocal();
    return BookingGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSectionHeader(
              cs: cs,
              icon: Iconsax.star_copy,
              color: star,
              title: 'review_yours_title'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Padding(
                    padding: EdgeInsetsDirectional.only(end: 2.r),
                    child: Icon(
                      i < review.rating ? Iconsax.star : Iconsax.star_1_copy,
                      size: 20.r,
                      color: star,
                    ),
                  ),
                ),
                if (created != null) ...[
                  const Spacer(),
                  Text(
                    DateFormat.yMMMd(context.locale.toString()).format(created),
                    style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ],
            ),
            if (comment.isNotEmpty) ...[
              SizedBox(height: 10.r),
              Text(
                comment,
                style: TextStyle(fontSize: 13.r, height: 1.4, color: cs.onSurface.withValues(alpha: 0.8)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
