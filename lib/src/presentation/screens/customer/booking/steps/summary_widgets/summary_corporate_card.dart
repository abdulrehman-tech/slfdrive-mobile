import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../profile/corporate/widgets/organization_logo.dart';
import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';

/// Summary entry shown only when the booking is corporate. Surfaces the
/// chosen organization plus a hint about the billing path.
class SummaryCorporateCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummaryCorporateCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final org = data.organization;
    if (!data.isCorporate || org == null) return const SizedBox.shrink();
    final isBilled = data.paymentMethod == PaymentMethod.billToCompany;
    final color = org.accentColor;
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
              OrganizationLogo(organization: org, size: 40.r, isDark: isDark),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: cs.onSurface),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      isBilled
                          ? 'summary_corporate_billed_to_company'.tr()
                          : 'summary_corporate_paid_personally'.tr(),
                      style: TextStyle(
                        fontSize: 11.r,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
