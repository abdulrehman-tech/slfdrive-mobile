import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color_constants.dart';
import '../profile_completion_models/language_option.dart';
import '../profile_completion_provider/profile_completion_provider.dart';
import 'dropdown_field.dart';
import 'input_field.dart';
import 'multi_select_field.dart';
import 'section_header.dart';

/// Driver-only "additional info" group: experience, languages, base location,
/// vehicle ownership and day/hour rates — covering every remaining field the
/// driver profile-completion endpoint accepts.
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
        _number(
          controller: provider.yearsExperienceController,
          hint: 'enter_years_experience'.tr(),
          label: 'years_driving_experience'.tr(),
          icon: Icons.timer_outlined,
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
        SizedBox(height: 16.r),
        DropdownField(
          value: provider.selectedLocationName,
          hint: provider.loadingLocations ? 'loading'.tr() : 'select_location'.tr(),
          label: 'driver_location'.tr(),
          icon: Icons.location_on_outlined,
          isDark: isDark,
          items: provider.locationNames,
          onChanged: provider.selectLocationByName,
        ),
        SizedBox(height: 16.r),
        _number(
          controller: provider.amountPerDayController,
          hint: 'enter_amount'.tr(),
          label: 'amount_per_day'.tr(),
          icon: Icons.payments_outlined,
        ),
        SizedBox(height: 16.r),
        _number(
          controller: provider.amountPerHourController,
          hint: 'enter_amount'.tr(),
          label: 'amount_per_hour'.tr(),
          icon: Icons.schedule_outlined,
        ),
        SizedBox(height: 16.r),
        _hasVehicleToggle(provider),
      ],
    );
  }

  Widget _number({
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
    }
    return InputField(
      controller: controller,
      hint: hint,
      label: label,
      icon: icon,
      isDark: isDark,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _hasVehicleToggle(ProfileCompletionProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car_filled_outlined,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
          SizedBox(width: 12.r),
          Expanded(
            child: Text(
              'has_own_vehicle'.tr(),
              style: TextStyle(
                fontSize: 14.r,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
              ),
            ),
          ),
          Switch(
            value: provider.hasVehicle,
            activeThumbColor: secondaryColor,
            onChanged: (value) => provider.hasVehicle = value,
          ),
        ],
      ),
    );
  }
}
