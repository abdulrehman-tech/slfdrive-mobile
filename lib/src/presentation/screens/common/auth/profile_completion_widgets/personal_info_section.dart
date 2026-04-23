import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/country_selector_field.dart';
import '../profile_completion_models/gender_option.dart';
import '../profile_completion_provider/profile_completion_provider.dart';
import 'dropdown_field.dart';
import 'input_field.dart';
import 'section_header.dart';

/// Personal-info form group (name, email, DOB, country, gender).
///
/// Shared across mobile and desktop layouts; the [desktop] flag swaps in the
/// larger input/header variants so both forms stay visually aligned.
class PersonalInfoSection extends StatelessWidget {
  final bool isDark;
  final bool desktop;
  final Future<void> Function(BuildContext) onPickDob;

  const PersonalInfoSection({
    super.key,
    required this.isDark,
    required this.onPickDob,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileCompletionProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        desktop
            ? SectionHeaderDesktop(label: 'section_personal_info'.tr(), isDark: isDark)
            : SectionHeader(label: 'section_personal_info'.tr(), isDark: isDark),
        SizedBox(height: 14.r),
        _textField(
          controller: provider.nameController,
          hint: 'enter_name'.tr(),
          label: 'full_name'.tr(),
          icon: Icons.person_outline,
        ),
        SizedBox(height: 16.r),
        _textField(
          controller: provider.emailController,
          hint: 'enter_email'.tr(),
          label: 'email'.tr(),
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.r),
        GestureDetector(
          onTap: () => onPickDob(context),
          child: AbsorbPointer(
            child: _textField(
              controller: provider.dobController,
              hint: 'DD/MM/YYYY',
              label: 'date_of_birth'.tr(),
              icon: Icons.calendar_today_outlined,
            ),
          ),
        ),
        SizedBox(height: 16.r),
        CountrySelectorField(
          selectedCountry: provider.selectedCountry,
          onCountrySelected: (country) => provider.selectedCountry = country,
          isDark: isDark,
          label: 'country'.tr(),
          icon: Icons.public_outlined,
        ),
        SizedBox(height: 16.r),
        DropdownField(
          value: provider.selectedGender,
          hint: 'select_gender'.tr(),
          label: 'gender'.tr(),
          icon: Icons.people_outline,
          isDark: isDark,
          items: kGenderOptions,
          onChanged: (value) => provider.selectedGender = value,
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    if (desktop) {
      return InputFieldDesktop(
        controller: controller,
        hint: hint,
        label: label,
        icon: icon,
        isDark: isDark,
        keyboardType: keyboardType,
      );
    }
    return InputField(
      controller: controller,
      hint: hint,
      label: label,
      icon: icon,
      isDark: isDark,
      keyboardType: keyboardType,
    );
  }
}
