import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../profile/corporate/models/organization.dart';
import '../../../profile/corporate/widgets/organization_logo.dart';
import '../../widgets/booking_glass_card.dart';

/// Confirmation card shown when the customer picks "Bill to company" — no
/// card capture needed, the invoice will route to the chosen organization.
class PaymentBillToCompanyCard extends StatelessWidget {
  final Organization organization;
  final bool isDark;

  const PaymentBillToCompanyCard({
    super.key,
    required this.organization,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = organization.accentColor;
    return BookingGlassCard(
      isDark: isDark,
      borderColor: color.withValues(alpha: 0.4),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OrganizationLogo(organization: organization, size: 44.r, isDark: isDark),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'booking_payment_bill_to_company'.tr(),
                      style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: color),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      organization.name,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              Icon(Iconsax.tick_circle_copy, size: 22.r, color: color),
            ],
          ),
          SizedBox(height: 12.r),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.1 : 0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.info_circle_copy, size: 16.r, color: color),
                SizedBox(width: 8.r),
                Expanded(
                  child: Text(
                    'booking_payment_bill_to_company_hint'.tr(),
                    style: TextStyle(
                      fontSize: 12.r,
                      color: cs.onSurface.withValues(alpha: 0.75),
                      height: 1.45,
                    ),
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
