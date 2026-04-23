import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../profile_completion_models/language_option.dart';
import '../profile_completion_provider/profile_completion_provider.dart';
import 'input_field.dart';
import 'multi_select_field.dart';
import 'section_header.dart';

/// Driver-only "additional info" group (years of experience + languages).
class DriverAdditionalInfoSection extends StatelessWidget {
  final bool isDark;
  final bool desktop;

  const DriverAdditionalInfoSection({super.key, required this.isDark, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileCompletionProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        desktop
            ? SectionHeaderDesktop(label: 'section_additional_info'.tr(), isDark: isDark)
            : SectionHeader(label: 'section_additional_info'.tr(), isDark: isDark),
        SizedBox(height: 14.r),
        if (desktop)
          InputFieldDesktop(
            controller: provider.yearsExperienceController,
            hint: 'enter_years_experience'.tr(),
            label: 'years_driving_experience'.tr(),
            icon: Icons.timer_outlined,
            isDark: isDark,
            keyboardType: TextInputType.number,
          )
        else
          InputField(
            controller: provider.yearsExperienceController,
            hint: 'enter_years_experience'.tr(),
            label: 'years_driving_experience'.tr(),
            icon: Icons.timer_outlined,
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
        SizedBox(height: 16.r),
        MultiSelectField(
          values: provider.selectedLanguages,
          hint: 'select_languages'.tr(),
          label: 'languages_spoken'.tr(),
          icon: Icons.language_outlined,
          isDark: isDark,
          items: kLanguageOptions,
          onChanged: (values) => provider.selectedLanguages = values,
        ),
      ],
    );
  }
}
