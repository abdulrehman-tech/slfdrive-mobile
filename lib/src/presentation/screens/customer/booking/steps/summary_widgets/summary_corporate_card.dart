import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';

/// Summary entry shown only for a corporate booking. Surfaces the chosen
/// company.
class SummaryCorporateCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummaryCorporateCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final company = data.company;
    if (!data.isCorporate || company == null) return const SizedBox.shrink();
    const color = Color(0xFF4D63DD);
    final logo = company.resolvedLogoUrl;
    return BookingGlassCard(
      isDark: isDark,
      borderColor: color.withValues(alpha: 0.35),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.briefcase_copy, size: 14.r, color: color),
              SizedBox(width: 6.r),
              Text(
                'summary_corporate_section_title'.tr(),
                style: TextStyle(
                  fontSize: 11.r,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.r),
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: logo != null
                    ? CachedNetworkImage(
                        imageUrl: logo,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) =>
                            Icon(Iconsax.buildings_copy, size: 18.r, color: color),
                      )
                    : Icon(Iconsax.buildings_copy, size: 18.r, color: color),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Text(
                  company.displayName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: cs.onSurface),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
