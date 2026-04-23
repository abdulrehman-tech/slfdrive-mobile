import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../widgets/omr_icon.dart';
import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';

class SummarySubjectCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummarySubjectCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = data;

    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(14.r),
      child: Column(
        children: [
          if (d.car != null)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: d.car!.imageUrl,
                    width: 72.r,
                    height: 56.r,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      width: 72.r,
                      height: 56.r,
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFEEEEEE),
                      child: Icon(Iconsax.car_copy, size: 24.r, color: cs.primary),
                    ),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.car!.name,
                        style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        d.car!.brand,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    OmrIcon(size: 12.r, color: cs.primary),
                    SizedBox(width: 3.r),
                    Text(
                      '${d.car!.pricePerDay.toStringAsFixed(0)}/d',
                      style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: cs.primary),
                    ),
                  ],
                ),
              ],
            ),
          if (d.car != null && d.driver != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.r),
              child: Divider(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          if (d.driver != null)
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: d.driver!.avatarUrl,
                  imageBuilder: (_, img) => Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: img, fit: BoxFit.cover),
                    ),
                  ),
                  errorWidget: (_, _, _) => CircleAvatar(
                    radius: 22.r,
                    backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                    child: Icon(Iconsax.user_copy, size: 18.r, color: cs.primary),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.driver!.name,
                        style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      SizedBox(height: 2.r),
                      Row(
                        children: [
                          Icon(Iconsax.star_1_copy, size: 11.r, color: const Color(0xFFFFC107)),
                          SizedBox(width: 2.r),
                          Text(
                            '${d.driver!.rating} · ${d.driver!.speciality}',
                            style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    OmrIcon(size: 11.r, color: cs.primary),
                    SizedBox(width: 3.r),
                    Text(
                      '${d.driver!.pricePerDay.toStringAsFixed(0)}/d',
                      style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w800, color: cs.primary),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
