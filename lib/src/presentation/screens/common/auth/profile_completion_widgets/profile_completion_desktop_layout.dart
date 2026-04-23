import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/icon_constants.dart';
import '../profile_completion_provider/profile_completion_provider.dart';
import 'driver_additional_info_section.dart';
import 'driver_documents_section.dart';
import 'driver_license_section.dart';
import 'pending_approval_note.dart';
import 'personal_info_section.dart';
import 'profile_avatar_picker.dart';
import 'submit_button.dart';

/// Desktop two-column layout: branding / form. RTL-aware.
class ProfileCompletionDesktopLayout extends StatelessWidget {
  final bool isDark;
  final bool isDriver;
  final Future<void> Function(BuildContext) onPickDob;
  final Future<void> Function(BuildContext) onPickLicenseExpiry;
  final VoidCallback onSubmit;

  const ProfileCompletionDesktopLayout({
    super.key,
    required this.isDark,
    required this.isDriver,
    required this.onPickDob,
    required this.onPickLicenseExpiry,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final brandingColumn = _brandingColumn(context);
    final formColumn = _formColumn(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: 80.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isRtl
              ? [formColumn, SizedBox(width: 60.r), brandingColumn]
              : [brandingColumn, SizedBox(width: 60.r), formColumn],
        ),
      ),
    );
  }

  Widget _brandingColumn(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(isDark ? IconConstants.logoWhite : IconConstants.logo, width: 160.r, height: 160.r),
          SizedBox(height: 32.r),
          Text(
            isDriver ? 'driver_profile_title'.tr() : 'profile_title'.tr(),
            style: TextStyle(
              fontSize: 44.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
          ),
          SizedBox(height: 14.r),
          Text(
            'profile_subtitle'.tr(),
            style: TextStyle(
              fontSize: 17.r,
              color: isDark ? Colors.white70 : const Color(0xFF757575),
              height: 1.6,
            ),
          ),
          if (isDriver) ...[
            SizedBox(height: 24.r),
            PendingApprovalNote(isDark: isDark),
          ],
        ],
      ),
    );
  }

  Widget _formColumn(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final provider = context.watch<ProfileCompletionProvider>();
    return Expanded(
      flex: 5,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                size: 22.r,
              ),
            ),
            SizedBox(height: 24.r),
            Center(
              child: ProfileAvatarPicker(
                picked: provider.avatarPicked,
                isDark: isDark,
                size: 110.r,
                onTap: provider.pickAvatar,
              ),
            ),
            SizedBox(height: 28.r),
            PersonalInfoSection(isDark: isDark, onPickDob: onPickDob, desktop: true),
            if (isDriver) ...[
              SizedBox(height: 28.r),
              DriverAdditionalInfoSection(isDark: isDark, desktop: true),
              SizedBox(height: 28.r),
              DriverLicenseSection(isDark: isDark, onPickExpiry: onPickLicenseExpiry, desktop: true),
              SizedBox(height: 28.r),
              DriverDocumentsSection(isDark: isDark, desktop: true),
            ],
            SizedBox(height: 36.r),
            SubmitButtonDesktop(
              label: isDriver ? 'submit_for_approval'.tr() : 'get_started'.tr(),
              enabled: provider.isButtonEnabled,
              onTap: onSubmit,
            ),
            SizedBox(height: 40.r),
          ],
        ),
      ),
    );
  }
}
