import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/car_detail_provider.dart';
import 'car_glass_card.dart';
import '../../../../widgets/company_link.dart';
import '../../../../widgets/network_logo.dart';

/// The rental company that lists the car — logo, name and a link to its
/// profile.
/// Contact actions (phone/WhatsApp) are omitted — the backend DTO
/// does not include owner contact details.
class OwnerSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const OwnerSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<CarDetailProvider>().vehicle;
    if (vehicle == null) return const SizedBox.shrink();

    // Prefer the owning company name (Arabic when available) over the
    // individual owner name.
    final ar = context.locale.languageCode == 'ar';
    final companyName = [if (ar) vehicle.companyNameAr, vehicle.companyName]
        .map((s) => s?.trim() ?? '')
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    final name = companyName.isNotEmpty ? companyName : vehicle.ownerName;
    if (name == null || name.isEmpty) return const SizedBox.shrink();

    final companyId = vehicle.companyId;

    final card = CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            CompanyAvatar(companyId: companyId, name: name, size: 52.r, radius: 14.r),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'company_listed_by'.tr(),
                    style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: cs.onSurface, height: 1.25),
                  ),
                  if (companyId != null) ...[
                    SizedBox(height: 3.r),
                    Text(
                      'company_view_profile'.tr(),
                      style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: cs.primary),
                    ),
                  ],
                ],
              ),
            ),
            if (companyId != null) ...[
              SizedBox(width: 8.r),
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1), shape: BoxShape.circle),
                child: Icon(Icons.chevron_right, size: 20.r, color: cs.primary),
              ),
            ],
          ],
        ),
      ),
    );
    if (companyId == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openCompanyProfile(context, companyId),
      child: card,
    );
  }
}
