import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../profile_completion_provider/profile_completion_provider.dart';
import 'input_field.dart';
import 'section_header.dart';

/// Driver license group: number, expiry (date picker), national id.
class DriverLicenseSection extends StatelessWidget {
  final bool isDark;
  final bool desktop;
  final Future<void> Function(BuildContext) onPickExpiry;

  const DriverLicenseSection({
    super.key,
    required this.isDark,
    required this.onPickExpiry,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileCompletionProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        desktop
            ? SectionHeaderDesktop(label: 'section_license'.tr(), isDark: isDark)
            : SectionHeader(label: 'section_license'.tr(), isDark: isDark),
        SizedBox(height: 14.r),
        _field(
          controller: provider.licenseNumberController,
          hint: 'enter_license_number'.tr(),
          label: 'license_number'.tr(),
          icon: Icons.badge_outlined,
        ),
        SizedBox(height: 16.r),
        GestureDetector(
          onTap: () => onPickExpiry(context),
          child: AbsorbPointer(
            child: _field(
              controller: provider.licenseExpiryController,
              hint: 'DD/MM/YYYY',
              label: 'license_expiry'.tr(),
              icon: Icons.calendar_today_outlined,
            ),
          ),
        ),
        SizedBox(height: 16.r),
        _field(
          controller: provider.nationalIdController,
          hint: 'enter_national_id'.tr(),
          label: 'national_id'.tr(),
          icon: Icons.credit_card_outlined,
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
  }) {
    if (desktop) {
      return InputFieldDesktop(
        controller: controller,
        hint: hint,
        label: label,
        icon: icon,
        isDark: isDark,
      );
    }
    return InputField(
      controller: controller,
      hint: hint,
      label: label,
      icon: icon,
      isDark: isDark,
    );
  }
}
