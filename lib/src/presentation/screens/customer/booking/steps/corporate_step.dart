import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../models/booking_data.dart';
import '../provider/corporate_companies_provider.dart';
import '../widgets/booking_glass_card.dart';
import 'corporate_widgets/corporate_company_picker.dart';
import 'corporate_widgets/corporate_toggle.dart';

/// Booking step where the user chooses personal vs corporate, and — when
/// corporate — picks the company they're booking for from the live
/// `AllCompanies/active` list.
class CorporateStep extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const CorporateStep({super.key, required this.data, required this.isDark});

  Future<void> _pickCompany(BuildContext context) async {
    final provider = context.read<CorporateCompaniesProvider>();
    await provider.ensureLoaded();
    if (!context.mounted) return;
    final picked = await showCompanyPickerSheet(
      context,
      companies: provider.companies,
      isDark: isDark,
      selected: data.company,
      isLoading: provider.isLoading,
      error: provider.error,
    );
    if (picked != null) data.setCorporate(true, company: picked);
  }

  void _handleToggle(BuildContext context, bool corporate) {
    if (!corporate) {
      data.setCorporate(false);
      return;
    }
    data.setCorporate(true, company: data.company);
    if (data.company == null) _pickCompany(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Companies load lazily when the user switches to corporate / opens the
    // picker (see _handleToggle / _pickCompany) — never during build, which
    // would notify listeners mid-build.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_step_corporate_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_step_corporate_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 22.r),
        BookingSectionHeader(
          icon: Iconsax.briefcase_copy,
          iconColor: const Color(0xFF4D63DD),
          title: 'booking_corporate_choose_mode'.tr(),
          isDark: isDark,
        ),
        SizedBox(height: 12.r),
        CorporateToggle(
          isCorporate: data.isCorporate,
          isDark: isDark,
          onChanged: (v) => _handleToggle(context, v),
        ),
        if (data.isCorporate) ...[
          SizedBox(height: 18.r),
          BookingSectionHeader(
            icon: Iconsax.buildings_copy,
            iconColor: const Color(0xFF4D63DD),
            title: 'booking_corporate_selected_company'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 12.r),
          _CompanySelector(
            company: data.company,
            isDark: isDark,
            onTap: () => _pickCompany(context),
          ),
        ],
      ],
    );
  }
}

class _CompanySelector extends StatelessWidget {
  final dynamic company; // AllCompany?
  final bool isDark;
  final VoidCallback onTap;
  const _CompanySelector({required this.company, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final logo = company?.resolvedLogoUrl as String?;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46.r,
              height: 46.r,
              decoration: BoxDecoration(
                color: const Color(0xFF4D63DD).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: (company != null && logo != null)
                  ? CachedNetworkImage(
                      imageUrl: logo,
                      fit: BoxFit.cover,
                      errorWidget: (c, u, e) =>
                          Icon(Iconsax.buildings_copy, size: 22.r, color: const Color(0xFF4D63DD)),
                    )
                  : Icon(Iconsax.buildings_copy, size: 22.r, color: const Color(0xFF4D63DD)),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Text(
                company != null
                    ? (company.displayName() as String)
                    : 'booking_corporate_select_company'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.r,
                  fontWeight: FontWeight.w700,
                  color: company != null ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            Icon(Iconsax.arrow_right_3_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
