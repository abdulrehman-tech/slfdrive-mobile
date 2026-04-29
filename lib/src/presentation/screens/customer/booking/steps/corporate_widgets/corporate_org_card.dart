import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../profile/corporate/models/organization.dart';
import '../../../profile/corporate/widgets/organization_logo.dart';
import '../../widgets/booking_glass_card.dart';

/// Card displayed once a corporate org is picked. Tapping re-opens the picker.
class CorporateOrgCard extends StatelessWidget {
  final Organization organization;
  final bool isDark;
  final VoidCallback onChange;

  const CorporateOrgCard({
    super.key,
    required this.organization,
    required this.isDark,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BookingGlassCard(
      isDark: isDark,
      onTap: onChange,
      borderColor: organization.accentColor.withValues(alpha: 0.4),
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          OrganizationLogo(organization: organization, size: 48.r, isDark: isDark),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organization.name,
                  style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w800, color: cs.onSurface),
                ),
                SizedBox(height: 2.r),
                Text(
                  organization.industry,
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
            decoration: BoxDecoration(
              color: organization.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.edit_2_copy, size: 12.r, color: organization.accentColor),
                SizedBox(width: 4.r),
                Text(
                  'booking_corporate_change'.tr(),
                  style: TextStyle(
                    fontSize: 11.r,
                    fontWeight: FontWeight.w700,
                    color: organization.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
