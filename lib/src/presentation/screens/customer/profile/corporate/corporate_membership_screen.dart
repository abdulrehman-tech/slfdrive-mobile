import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/breakpoints.dart';
import '../../../../../constants/color_constants.dart';
import '../../../../providers/theme_provider.dart';
import '../../../common/auth/profile_completion_widgets/section_header.dart';
import '../../../common/auth/profile_completion_widgets/submit_button.dart';
import '../../../common/profile/widgets/profile_section.dart';
import 'models/corporate_membership.dart';
import 'models/membership_status.dart';
import 'models/organization.dart';
import 'provider/corporate_provider.dart';
import 'widgets/membership_status_badge.dart';
import 'widgets/organization_logo.dart';

/// Status / detail screen for the user's corporate membership(s).
class CorporateMembershipScreen extends StatelessWidget {
  const CorporateMembershipScreen({super.key});

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final corporate = context.watch<CorporateProvider>();
    final latest = corporate.latestMembership;
    final org = latest != null ? corporate.organizationById(latest.organizationId) : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
            final isTablet = Breakpoints.isTablet(constraints.maxWidth);
            final maxWidth = isDesktop ? 720.0 : (isTablet ? 640.0 : double.infinity);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    _Header(isDark: isDark, status: corporate.effectiveStatus),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 28.r),
                        child: _Body(
                          isDark: isDark,
                          status: corporate.effectiveStatus,
                          membership: latest,
                          organization: org,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  final MembershipStatus status;
  const _Header({required this.isDark, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 8.r),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
                ),
              ),
              child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
            ),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Text(
              'profile_corporate_membership'.tr(),
              style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.w800, color: cs.onSurface),
            ),
          ),
          MembershipStatusBadge(status: status, isDark: isDark),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final bool isDark;
  final MembershipStatus status;
  final CorporateMembership? membership;
  final Organization? organization;

  const _Body({
    required this.isDark,
    required this.status,
    required this.membership,
    required this.organization,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(status: status, organization: organization, isDark: isDark),
        SizedBox(height: 20.r),
        if (status == MembershipStatus.rejected && membership?.rejectionReason != null) ...[
          _RejectionBanner(reason: membership!.rejectionReason!, isDark: isDark),
          SizedBox(height: 16.r),
        ],
        if (membership != null) ...[
          _DetailsSection(isDark: isDark, membership: membership!, organization: organization),
          SizedBox(height: 20.r),
        ],
        _ActionButton(status: status),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final MembershipStatus status;
  final Organization? organization;
  final bool isDark;
  const _HeroCard({required this.status, required this.organization, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final showBrandHero = status == MembershipStatus.approved && organization != null;
    if (showBrandHero) {
      // Approved → brand gradient hero with the org branding overlaid.
      return Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.35),
              blurRadius: 20.r,
              offset: Offset(0, 8.r),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: OrganizationLogo(organization: organization!, size: 44.r, isDark: false),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'corporate_status_approved'.tr().toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.r,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        organization!.name,
                        style: TextStyle(
                          fontSize: 18.r,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.tick_circle, size: 24.r, color: Colors.white),
              ],
            ),
            SizedBox(height: 14.r),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Iconsax.info_circle_copy, size: 16.r, color: Colors.white),
                  SizedBox(width: 8.r),
                  Expanded(
                    child: Text(
                      'corporate_status_approved_msg'.tr(),
                      style: TextStyle(
                        fontSize: 12.r,
                        color: Colors.white,
                        height: 1.5,
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

    // Pending / rejected / not-applied → tinted card matching status color.
    final color = status.color;
    final messageKey = switch (status) {
      MembershipStatus.notApplied => 'corporate_status_not_applied_msg',
      MembershipStatus.pending => 'corporate_status_pending_msg',
      MembershipStatus.rejected => 'corporate_status_rejected_msg',
      MembershipStatus.approved => '',
    };
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.28 : 0.18),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(status.icon, size: 24.r, color: color),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w800, color: color),
                ),
                SizedBox(height: 6.r),
                Text(
                  messageKey.tr(),
                  style: TextStyle(
                    fontSize: 13.r,
                    color: isDark ? Colors.white70 : const Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                if (organization != null) ...[
                  SizedBox(height: 12.r),
                  Row(
                    children: [
                      OrganizationLogo(organization: organization!, size: 28.r, isDark: isDark),
                      SizedBox(width: 8.r),
                      Text(
                        organization!.name,
                        style: TextStyle(
                          fontSize: 13.r,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectionBanner extends StatelessWidget {
  final String reason;
  final bool isDark;
  const _RejectionBanner({required this.reason, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFE53935);
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.warning_2_copy, size: 18.r, color: color),
          SizedBox(width: 10.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'corporate_rejection_reason'.tr(),
                  style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w800, color: color),
                ),
                SizedBox(height: 4.r),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 13.r,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    height: 1.4,
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

class _DetailsSection extends StatelessWidget {
  final bool isDark;
  final CorporateMembership membership;
  final Organization? organization;
  const _DetailsSection({
    required this.isDark,
    required this.membership,
    required this.organization,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(label: 'corporate_employment_details'.tr(), isDark: isDark),
        SizedBox(height: 12.r),
        ProfileSection(
          title: '',
          isDark: isDark,
          children: [
            _Row(
              icon: Iconsax.buildings_copy,
              iconColor: organization?.accentColor ?? primaryColor,
              label: 'corporate_field_organization'.tr(),
              value: organization?.name ?? '—',
              isDark: isDark,
            ),
            _Row(
              icon: Iconsax.personalcard_copy,
              iconColor: const Color(0xFF7C4DFF),
              label: 'corporate_field_employee_id'.tr(),
              value: membership.employeeId,
              isDark: isDark,
            ),
            _Row(
              icon: Iconsax.briefcase_copy,
              iconColor: const Color(0xFF3D5AFE),
              label: 'corporate_field_position'.tr(),
              value: membership.position,
              isDark: isDark,
            ),
            _Row(
              icon: Iconsax.category_2_copy,
              iconColor: const Color(0xFF00BCD4),
              label: 'corporate_field_department'.tr(),
              value: membership.department,
              isDark: isDark,
            ),
            _Row(
              icon: Iconsax.sms_copy,
              iconColor: const Color(0xFF4CAF50),
              label: 'corporate_field_work_email'.tr(),
              value: membership.workEmail,
              isDark: isDark,
            ),
            _Row(
              icon: Iconsax.calendar_2_copy,
              iconColor: const Color(0xFFFFA726),
              label: 'corporate_field_join_date'.tr(),
              value:
                  '${membership.joinDate.year}-${membership.joinDate.month.toString().padLeft(2, '0')}-${membership.joinDate.day.toString().padLeft(2, '0')}',
              isDark: isDark,
            ),
            _Row(
              icon: Iconsax.user_copy,
              iconColor: const Color(0xFF7C4DFF),
              label: 'corporate_field_manager'.tr(),
              value: membership.managerName,
              isDark: isDark,
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;
  const _Row({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(10.r, 10.r, 10.r, isLast ? 10.r : 10.r),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.r, color: iconColor),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                ),
                SizedBox(height: 2.r),
                Text(
                  value,
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final MembershipStatus status;
  const _ActionButton({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == MembershipStatus.pending || status == MembershipStatus.approved) {
      return const SizedBox.shrink();
    }
    final labelKey = status == MembershipStatus.rejected
        ? 'corporate_action_reapply'
        : 'corporate_action_apply';
    return SubmitButton(
      label: labelKey.tr(),
      enabled: true,
      onTap: () => context.push('/profile/corporate/apply'),
    );
  }
}
