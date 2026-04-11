import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:intl_phone_field/countries.dart';

class CustomPhoneField extends StatefulWidget {
  final Function(String completeNumber, String dialCode) onChanged;
  final bool isDark;
  final String initialCountryCode;

  const CustomPhoneField({super.key, required this.onChanged, required this.isDark, this.initialCountryCode = 'OM'});

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  final TextEditingController _controller = TextEditingController();
  late Country _selectedCountry;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedCountry = countries.firstWhere(
      (country) => country.code == widget.initialCountryCode,
      orElse: () => countries.first,
    );
    _controller.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final phoneNumber = _controller.text;
    if (phoneNumber.isEmpty) {
      setState(() => _errorText = null);
      widget.onChanged('', _selectedCountry.dialCode);
      return;
    }

    // Basic validation
    if (phoneNumber.length < 7) {
      setState(() => _errorText = 'invalid_phone_number'.tr());
    } else {
      setState(() => _errorText = null);
    }

    final completeNumber = '+${_selectedCountry.dialCode}$phoneNumber';
    widget.onChanged(completeNumber, _selectedCountry.dialCode);
  }

  void _showCountryPicker() {
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
              color: widget.isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                SizedBox(height: 8.r),
                Container(
                  width: 40.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.white24 : Colors.black26,
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
                          'select_country_code'.tr(),
                          style: TextStyle(
                            fontSize: 20.r,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : const Color(0xFF3D3D3D),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: widget.isDark ? Colors.white70 : const Color(0xFF757575),
                          size: 24.r,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.r),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: widget.isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setModalState(() {}),
                      style: TextStyle(fontSize: 16.r, color: widget.isDark ? Colors.white : const Color(0xFF3D3D3D)),
                      decoration: InputDecoration(
                        hintText: 'search_country'.tr(),
                        hintStyle: TextStyle(
                          fontSize: 16.r,
                          color: widget.isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: widget.isDark ? Colors.white38 : const Color(0xFF9E9E9E),
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
                      final isSelected = _selectedCountry.code == country.code;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;
                              _controller.clear();
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 14.r),
                            margin: EdgeInsets.only(bottom: 4.r),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (widget.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F4FF))
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
                                      color: widget.isDark ? Colors.white : const Color(0xFF3D3D3D),
                                    ),
                                  ),
                                ),
                                Text(
                                  '+${country.dialCode}',
                                  style: TextStyle(
                                    fontSize: 16.r,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDark ? Colors.white70 : const Color(0xFF757575),
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
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _errorText != null ? Colors.red : (widget.isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: _showCountryPicker,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 18.r),
                  child: Row(
                    children: [
                      Text(_selectedCountry.flag, style: TextStyle(fontSize: 24.r)),
                      SizedBox(width: 8.r),
                      Text(
                        '+${_selectedCountry.dialCode}',
                        style: TextStyle(
                          fontSize: 16.r,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? Colors.white : const Color(0xFF3D3D3D),
                        ),
                      ),
                      SizedBox(width: 4.r),
                      Icon(
                        Icons.arrow_drop_down,
                        color: widget.isDark ? Colors.white70 : const Color(0xFF757575),
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 40.r, color: widget.isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontSize: 16.r,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : const Color(0xFF3D3D3D),
                  ),
                  decoration: InputDecoration(
                    hintText: 'enter_phone_number'.tr(),
                    hintStyle: TextStyle(
                      fontSize: 16.r,
                      color: widget.isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 18.r),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errorText != null) ...[
          SizedBox(height: 8.r),
          Padding(
            padding: EdgeInsets.only(left: 16.r),
            child: Text(
              _errorText!,
              style: TextStyle(fontSize: 12.r, color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }
}
