import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../core/models/company/all_company.dart';
import '../../corporate/provider/corporate_membership_provider.dart';
import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';
import 'corporate_widgets/corporate_company_picker.dart';
import 'corporate_widgets/corporate_toggle.dart';

/// Booking step where the user chooses personal vs corporate. Corporate is only
/// available when the user has an approved + active corporate membership. The
/// membership status (loading / error / not-eligible) is revealed only after the
/// user taps the Corporate option — never on a personal booking. The company
/// picker is sourced from the user's approved memberships.
class CorporateStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const CorporateStep({super.key, required this.data, required this.isDark});

  @override
  State<CorporateStep> createState() => _CorporateStepState();
}

class _CorporateStepState extends State<CorporateStep> {
  /// True once the user taps Corporate; gates the membership status note so it
  /// never shows while Personal is selected.
  bool _attemptedCorporate = false;

  BookingData get data => widget.data;
  bool get isDark => widget.isDark;

  /// Approved-membership companies (resolved to real [AllCompany]s with logos
  /// where available — see [CorporateMembershipProvider.approvedCompanies]).
  List<AllCompany> _eligibleCompanies(CorporateMembershipProvider p) => p.approvedCompanies;

  Future<void> _pickCompany() async {
    final p = context.read<CorporateMembershipProvider>();
    final companies = _eligibleCompanies(p);
    // Single eligible company → auto-select, skip the picker.
    if (companies.length == 1) {
      data.setCorporate(true, company: companies.first);
      return;
    }
    final picked = await showCompanyPickerSheet(
      context,
      companies: companies,
      isDark: isDark,
      selected: data.company,
      isLoading: p.isLoading,
      error: p.error,
    );
    if (picked != null) data.setCorporate(true, company: picked);
  }

  void _handleToggle(bool corporate) {
    if (!corporate) {
      setState(() => _attemptedCorporate = false);
      data.setCorporate(false);
      return;
    }
    setState(() => _attemptedCorporate = true);
    final membership = context.read<CorporateMembershipProvider>();
    // Not eligible (or still loading / errored) → leave the booking personal and
    // let the status note explain why; don't flip the booking to corporate.
    if (!membership.hasApprovedMembership) {
      if (!membership.hasLoaded && !membership.isLoading) membership.load();
      return;
    }
    data.setCorporate(true, company: data.company);
    if (data.company == null) _pickCompany();
  }

  Future<void> _goApply() async {
    await context.push('/profile/corporate');
    if (!mounted) return;
    // Refresh after the user may have applied/been approved.
    context.read<CorporateMembershipProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final membership = context.watch<CorporateMembershipProvider>();
    final canCorporate = membership.hasApprovedMembership;

    // If the user lost eligibility (e.g. membership revoked), drop any stale
    // corporate selection so they can't proceed with it.
    if (data.isCorporate && membership.hasLoaded && !canCorporate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => data.setCorporate(false));
    }

    // Status note only after a corporate attempt and only while ineligible.
    final showNote = _attemptedCorporate && !canCorporate;

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
          // Always tappable: tapping Corporate reveals the membership status
          // rather than being silently blocked.
          onChanged: _handleToggle,
        ),
        if (showNote) ...[
          SizedBox(height: 12.r),
          _MembershipNote(
            isLoading: membership.isLoading && !membership.hasLoaded,
            error: membership.error,
            isDark: isDark,
            onApply: _goApply,
            onRetry: () => context.read<CorporateMembershipProvider>().load(),
          ),
        ],
        if (data.isCorporate && canCorporate) ...[
          SizedBox(height: 18.r),
          BookingSectionHeader(
            icon: Iconsax.buildings_copy,
            iconColor: const Color(0xFF4D63DD),
            title: 'booking_corporate_selected_company'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 12.r),
          _CompanySelector(company: data.company, isDark: isDark, onTap: _pickCompany),
        ],
      ],
    );
  }
}

/// Shown when the user can't make a corporate booking. Three states:
/// loading (checking), error (membership lookup failed → retry), and the
/// default no-membership prompt (→ apply).
class _MembershipNote extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isDark;
  final VoidCallback onApply;
  final VoidCallback onRetry;
  const _MembershipNote({
    required this.isLoading,
    required this.error,
    required this.isDark,
    required this.onApply,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isError = !isLoading && error != null;
    // Error → red/retry; loading/no-membership → amber/apply.
    final accent = isError ? const Color(0xFFE53935) : const Color(0xFFFFA726);

    final String message;
    if (isLoading) {
      message = 'corporate_membership_checking'.tr();
    } else if (isError) {
      message = 'corporate_membership_load_error'.tr();
    } else {
      message = 'booking_corporate_membership_required'.tr();
    }

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.12 : 0.10),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(isError ? Iconsax.warning_2_copy : Iconsax.info_circle_copy, size: 20.r, color: accent),
          SizedBox(width: 12.r),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5.r, height: 1.35, color: cs.onSurface.withValues(alpha: 0.75)),
            ),
          ),
          if (!isLoading) ...[
            SizedBox(width: 8.r),
            TextButton(
              onPressed: isError ? onRetry : onApply,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10.r),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text((isError ? 'retry' : 'corporate_membership_apply').tr()),
            ),
          ],
        ],
      ),
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
                company != null ? (company.displayName() as String) : 'booking_corporate_select_company'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.r,
                  fontWeight: FontWeight.w700,
                  color: company != null ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            // Icon(Iconsax.arrow_right_3_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
