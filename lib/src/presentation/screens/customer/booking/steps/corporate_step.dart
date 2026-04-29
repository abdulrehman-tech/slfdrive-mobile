import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../profile/corporate/models/membership_status.dart';
import '../../profile/corporate/provider/corporate_provider.dart';
import '../../profile/corporate/widgets/organization_picker_sheet.dart';
import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';
import 'corporate_widgets/corporate_org_card.dart';
import 'corporate_widgets/corporate_status_note.dart';
import 'corporate_widgets/corporate_toggle.dart';

class CorporateStep extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const CorporateStep({super.key, required this.data, required this.isDark});

  Future<void> _pickOrganization(BuildContext context) async {
    final corporate = context.read<CorporateProvider>();
    final picked = await showOrganizationPickerSheet(
      context,
      organizations: corporate.approvedOrganizations,
      isDark: isDark,
      selected: data.organization,
      titleKey: 'booking_corporate_select_org',
    );
    if (picked != null) data.setCorporate(true, organization: picked);
  }

  void _handleToggle(BuildContext context, bool corporate) {
    final corp = context.read<CorporateProvider>();
    if (!corporate) {
      data.setCorporate(false);
      return;
    }
    if (corp.effectiveStatus != MembershipStatus.approved) {
      // Cannot become corporate — keep as personal; the inline note explains.
      data.setCorporate(false);
      return;
    }
    final approved = corp.approvedOrganizations;
    if (approved.length == 1) {
      data.setCorporate(true, organization: approved.first);
    } else {
      data.setCorporate(true);
      _pickOrganization(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final corporate = context.watch<CorporateProvider>();
    final status = corporate.effectiveStatus;
    final isApproved = status == MembershipStatus.approved;
    final approvedOrgs = corporate.approvedOrganizations;

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
          corporateDisabled: !isApproved,
          onChanged: (v) => _handleToggle(context, v),
        ),
        if (data.isCorporate && data.organization != null) ...[
          SizedBox(height: 18.r),
          BookingSectionHeader(
            icon: Iconsax.buildings_copy,
            iconColor: data.organization!.accentColor,
            title: 'booking_corporate_selected_org'.tr(),
            isDark: isDark,
            trailing: approvedOrgs.length > 1
                ? TextButton.icon(
                    onPressed: () => _pickOrganization(context),
                    style: TextButton.styleFrom(
                      foregroundColor: data.organization!.accentColor,
                      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(Iconsax.arrow_swap_horizontal_copy, size: 13.r),
                    label: Text(
                      'booking_corporate_switch_org'.tr(),
                      style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w800),
                    ),
                  )
                : null,
          ),
          SizedBox(height: 12.r),
          CorporateOrgCard(
            organization: data.organization!,
            isDark: isDark,
            onChange: () => _pickOrganization(context),
          ),
        ],
        if (!isApproved) ...[
          SizedBox(height: 18.r),
          CorporateStatusNote(status: status, isDark: isDark),
        ],
      ],
    );
  }
}
