import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../constants/icon_constants.dart';
import '../../../../../constants/color_constants.dart';
import '../../../../../constants/breakpoints.dart';

class PhoneLoginScreen extends StatefulWidget {
  final bool isDriver;

  const PhoneLoginScreen({super.key, this.isDriver = false});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+968';
  bool _isButtonEnabled = false;

  List<Map<String, dynamic>> get countryCodes => [
    {'code': '+968', 'flag': '🇴🇲', 'country': 'Oman'.tr(), 'digits': 8, 'hint': '9X XXX XXX'},
    {'code': '+971', 'flag': '🇦🇪', 'country': 'UAE'.tr(), 'digits': 9, 'hint': '5X XXX XXXX'},
    {'code': '+966', 'flag': '🇸🇦', 'country': 'Saudi Arabia'.tr(), 'digits': 9, 'hint': '5X XXX XXXX'},
    {'code': '+965', 'flag': '🇰🇼', 'country': 'Kuwait'.tr(), 'digits': 8, 'hint': 'XXXX XXXX'},
    {'code': '+974', 'flag': '🇶🇦', 'country': 'Qatar'.tr(), 'digits': 8, 'hint': 'XXXX XXXX'},
    {'code': '+973', 'flag': '🇧🇭', 'country': 'Bahrain'.tr(), 'digits': 8, 'hint': 'XXXX XXXX'},
  ];

  Map<String, dynamic> get _selectedCountry => countryCodes.firstWhere((c) => c['code'] == _selectedCountryCode);

  int get _maxDigits => _selectedCountry['digits'] as int;
  String get _hintText => _selectedCountry['hint'] as String;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isButtonEnabled = _phoneController.text.length == _maxDigits;
    });
  }

  void _onContinue() {
    if (_isButtonEnabled) {
      context.push(
        '/auth/otp',
        extra: {'phone': '$_selectedCountryCode${_phoneController.text}', 'isDriver': widget.isDriver},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

          if (isDesktop) {
            return _buildDesktopLayout(isDark);
          }

          return _buildMobileLayout(isDark);
        },
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          // Header with back button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
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
                  SizedBox(height: 20.r),

                  // Logo
                  Center(
                    child: SvgPicture.asset(
                      isDark ? IconConstants.logoWhite : IconConstants.logo,
                      width: 120.r,
                      height: 120.r,
                    ),
                  ),

                  SizedBox(height: 40.r),

                  // Title
                  Text(
                    widget.isDriver ? 'driver_phone_title'.tr() : 'phone_title'.tr(),
                    style: TextStyle(
                      fontSize: 28.r,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),

                  SizedBox(height: 12.r),

                  // Subtitle
                  Text(
                    'phone_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 16.r,
                      color: isDark ? Colors.white70 : const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 40.r),

                  // Phone Input
                  Text(
                    'phone_number'.tr(),
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),

                  SizedBox(height: 12.r),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                    ),
                    child: Row(
                      children: [
                        // Country Code Selector
                        InkWell(
                          onTap: () => _showCountryCodePicker(isDark),
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 18.r),
                            child: Row(
                              children: [
                                Text(_selectedCountry['flag'] as String, style: TextStyle(fontSize: 24.r)),
                                SizedBox(width: 8.r),
                                Text(
                                  _selectedCountryCode,
                                  style: TextStyle(
                                    fontSize: 16.r,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                                  ),
                                ),
                                SizedBox(width: 4.r),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: isDark ? Colors.white70 : const Color(0xFF757575),
                                  size: 20.r,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(width: 1, height: 40.r, color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),

                        // Phone Number Input
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: TextStyle(
                              fontSize: 16.r,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                            ),
                            maxLength: _maxDigits,
                            decoration: InputDecoration(
                              hintText: _hintText,
                              hintStyle: TextStyle(
                                fontSize: 16.r,
                                color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
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

                  SizedBox(height: 40.r),

                  // Continue Button
                  Container(
                    width: double.infinity,
                    height: 56.r,
                    decoration: BoxDecoration(
                      gradient: _isButtonEnabled
                          ? const LinearGradient(
                              colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: _isButtonEnabled ? null : (isDark ? Colors.grey[800] : const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isButtonEnabled ? _onContinue : null,
                        borderRadius: BorderRadius.circular(16.r),
                        child: Center(
                          child: Text(
                            'continue'.tr(),
                            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    final brandingColumn = Expanded(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(isDark ? IconConstants.logoWhite : IconConstants.logo, width: 180.r, height: 180.r),
          SizedBox(height: 40.r),
          Text(
            widget.isDriver ? 'driver_phone_title'.tr() : 'phone_title'.tr(),
            style: TextStyle(
              fontSize: 48.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
          ),
          SizedBox(height: 16.r),
          Text(
            'phone_subtitle'.tr(),
            style: TextStyle(fontSize: 18.r, color: isDark ? Colors.white70 : const Color(0xFF757575), height: 1.6),
          ),
        ],
      ),
    );

    final formColumn = Expanded(
      flex: 4,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                size: 24.r,
              ),
            ),
            SizedBox(height: 40.r),
            Text(
              'phone_number'.tr(),
              style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.r),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _showCountryCodePicker(isDark),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 20.r),
                      child: Row(
                        children: [
                          Text(_selectedCountry['flag'] as String, style: const TextStyle(fontSize: 28)),
                          SizedBox(width: 12.r),
                          Text(
                            _selectedCountryCode,
                            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8.r),
                          Icon(Icons.arrow_drop_down, size: 24.r),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1.r, height: 50.r, color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600),
                      maxLength: _maxDigits,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600),
                        hintText: _hintText,
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 20.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.r),
            Container(
              width: double.infinity,
              height: 60.r,
              decoration: BoxDecoration(
                gradient: _isButtonEnabled
                    ? const LinearGradient(
                        colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: _isButtonEnabled ? null : (isDark ? Colors.grey[800] : const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isButtonEnabled ? _onContinue : null,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Center(
                    child: Text(
                      'continue'.tr(),
                      style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: 80.r),
        child: Row(
          children: isRtl
              ? [formColumn, SizedBox(width: 80.r), brandingColumn]
              : [brandingColumn, SizedBox(width: 80.r), formColumn],
        ),
      ),
    );
  }

  void _showCountryCodePicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'select_country_code'.tr(),
              style: TextStyle(
                fontSize: 18.r,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
              ),
            ),
            SizedBox(height: 16.r),
            ...countryCodes.map(
              (country) => ListTile(
                leading: Text(country['flag'] as String, style: TextStyle(fontSize: 28.r)),
                title: Text(
                  country['country'] as String,
                  style: TextStyle(
                    fontSize: 16.r,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                  ),
                ),
                trailing: Text(
                  country['code'] as String,
                  style: TextStyle(fontSize: 16.r, color: isDark ? Colors.white70 : const Color(0xFF757575)),
                ),
                selected: _selectedCountryCode == country['code'] as String,
                selectedColor: secondaryColor,
                onTap: () {
                  setState(() {
                    _selectedCountryCode = country['code'] as String;
                    _phoneController.clear();
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
