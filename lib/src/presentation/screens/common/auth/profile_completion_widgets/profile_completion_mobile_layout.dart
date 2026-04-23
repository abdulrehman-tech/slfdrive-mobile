import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../profile_completion_provider/profile_completion_provider.dart';
import 'driver_additional_info_section.dart';
import 'driver_documents_section.dart';
import 'driver_license_section.dart';
import 'pending_approval_note.dart';
import 'personal_info_section.dart';
import 'profile_avatar_picker.dart';
import 'submit_button.dart';

/// Mobile (phone/tablet portrait) layout for profile completion.
class ProfileCompletionMobileLayout extends StatelessWidget {
  final bool isDark;
  final bool isDriver;
  final Future<void> Function(BuildContext) onPickDob;
  final Future<void> Function(BuildContext) onPickLicenseExpiry;
  final VoidCallback onSubmit;

  const ProfileCompletionMobileLayout({
    super.key,
    required this.isDark,
    required this.isDriver,
    required this.onPickDob,
    required this.onPickLicenseExpiry,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileCompletionProvider>();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    size: 20.r,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.r),
                  Text(
                    isDriver ? 'driver_profile_title'.tr() : 'profile_title'.tr(),
                    style: TextStyle(
                      fontSize: 26.r,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),
                  SizedBox(height: 6.r),
                  Text(
                    'profile_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 14.r,
                      color: isDark ? Colors.white70 : const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.r),
                  Center(
                    child: ProfileAvatarPicker(
                      picked: provider.avatarPicked,
                      isDark: isDark,
                      size: 100.r,
                      onTap: provider.pickAvatar,
                    ),
                  ),
                  SizedBox(height: 28.r),
                  PersonalInfoSection(isDark: isDark, onPickDob: onPickDob),
                  if (isDriver) ...[
                    SizedBox(height: 28.r),
                    DriverAdditionalInfoSection(isDark: isDark),
                    SizedBox(height: 28.r),
                    DriverLicenseSection(isDark: isDark, onPickExpiry: onPickLicenseExpiry),
                    SizedBox(height: 28.r),
                    DriverDocumentsSection(isDark: isDark),
                    SizedBox(height: 20.r),
                    PendingApprovalNote(isDark: isDark),
                  ],
                  SizedBox(height: 32.r),
                  SubmitButton(
                    label: isDriver ? 'submit_for_approval'.tr() : 'get_started'.tr(),
                    enabled: provider.isButtonEnabled,
                    onTap: onSubmit,
                  ),
                  SizedBox(height: 32.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
