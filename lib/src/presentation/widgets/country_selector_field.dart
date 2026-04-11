import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:intl_phone_field/countries.dart';

/// Unified country selector field that shows a beautiful bottom sheet
/// Uses the complete country list from intl_phone_field package (250+ countries)
class CountrySelectorField extends StatelessWidget {
  final Country? selectedCountry;
  final Function(Country) onCountrySelected;
  final bool isDark;
  final String? label;
  final IconData? icon;

  const CountrySelectorField({
    super.key,
    this.selectedCountry,
    required this.onCountrySelected,
    required this.isDark,
    this.label,
    this.icon,
  });

  void _showCountryPicker(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredCountries = searchController.text.isEmpty
              ? countries
              : countries.where((country) {
                  final searchLower = searchController.text.toLowerCase();
                  return country.name.toLowerCase().contains(searchLower) ||
                      country.dialCode.contains(searchController.text);
                }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                SizedBox(height: 8.r),
                Container(
                  width: 40.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.r),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.r),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label ?? 'select_country'.tr(),
                          style: TextStyle(
                            fontSize: 20.r,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF757575), size: 24.r),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.r),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setModalState(() {}),
                      style: TextStyle(fontSize: 16.r, color: isDark ? Colors.white : const Color(0xFF3D3D3D)),
                      decoration: InputDecoration(
                        hintText: 'search_country'.tr(),
                        hintStyle: TextStyle(fontSize: 16.r, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                          size: 22.r,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.r),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCountries.length,
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    itemBuilder: (context, index) {
                      final country = filteredCountries[index];
                      final isSelected = selectedCountry?.code == country.code;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onCountrySelected(country);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 14.r),
                            margin: EdgeInsets.only(bottom: 4.r),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F4FF))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF4D63DD) : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(country.flag, style: TextStyle(fontSize: 28.r)),
                                SizedBox(width: 16.r),
                                Expanded(
                                  child: Text(
                                    country.name,
                                    style: TextStyle(
                                      fontSize: 16.r,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  SizedBox(width: 12.r),
                                  Icon(Icons.check_circle, color: const Color(0xFF4D63DD), size: 20.r),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13.r,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF555555),
            ),
          ),
          SizedBox(height: 8.r),
        ],
        GestureDetector(
          onTap: () => _showCountryPicker(context),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 16.r),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
                  SizedBox(width: 12.r),
                ],
                if (selectedCountry != null) ...[
                  Text(selectedCountry!.flag, style: TextStyle(fontSize: 24.r)),
                  SizedBox(width: 12.r),
                ],
                Expanded(
                  child: Text(
                    selectedCountry?.name ?? 'select_country'.tr(),
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: FontWeight.w500,
                      color: selectedCountry == null
                          ? (isDark ? Colors.white38 : const Color(0xFF9E9E9E))
                          : (isDark ? Colors.white : const Color(0xFF3D3D3D)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
