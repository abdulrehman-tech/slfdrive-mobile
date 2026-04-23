import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_review.dart';

class ReviewTile extends StatelessWidget {
  final DriverReview review;
  final int index;
  final ColorScheme cs;
  final bool isDark;

  const ReviewTile({
    super.key,
    required this.review,
    required this.index,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0 : 12.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                review.author[0],
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: cs.primary),
              ),
            ),
          ),
          SizedBox(width: 10.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.author,
                        style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                    ),
                    Text(
                      review.timeAgo,
                      style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
                SizedBox(height: 2.r),
                Row(
                  children: List.generate(
                    5,
                    (si) => Icon(
                      si < review.rating.round() ? Iconsax.star_1_copy : Iconsax.star_1,
                      size: 10.r,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  review.text,
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.6), height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
