import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/company/all_company.dart';

/// Compact chip rendered in the booking flow header once a corporate booking
/// is locked in — keeps the mode + company visible across every step.
class CorporateChip extends StatelessWidget {
  final AllCompany company;
  final bool isDark;
  const CorporateChip({super.key, required this.company, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF4D63DD);
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(8.r, 4.r, 10.r, 4.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.briefcase_copy, size: 12.r, color: color),
          SizedBox(width: 6.r),
          Flexible(
            child: Text(
              'booking_corporate_chip'.tr(namedArgs: {'org': company.displayName()}),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.r,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
