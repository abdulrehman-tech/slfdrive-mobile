import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../constants/icon_constants.dart';
import '../../../../../constants/breakpoints.dart';
import '../../../../widgets/custom_phone_field.dart';

class PhoneLoginScreen extends StatefulWidget {
  final bool isDriver;

  const PhoneLoginScreen({super.key, this.isDriver = false});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  String _completePhoneNumber = '';
  String _selectedDeliveryMethod = 'sms';
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPhoneChanged(String completeNumber, String dialCode) {
    setState(() {
      _completePhoneNumber = completeNumber;
      _isButtonEnabled = completeNumber.isNotEmpty && completeNumber.length >= (dialCode.length + 8);
    });
  }

  void _onContinue() {
    if (_isButtonEnabled && _completePhoneNumber.isNotEmpty) {
      context.push(
        '/auth/otp',
        extra: {'phone': _completePhoneNumber, 'isDriver': widget.isDriver, 'deliveryMethod': _selectedDeliveryMethod},
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
                  CustomPhoneField(onChanged: _onPhoneChanged, isDark: isDark, initialCountryCode: 'OM'),

                  SizedBox(height: 24.r),

                  // OTP Delivery Method Selection
                  Text(
                    'otp_delivery_method'.tr(),
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),

                  SizedBox(height: 12.r),

                  Row(
                    children: [
                      Expanded(child: _buildDeliveryChip('sms', 'otp_via_sms'.tr(), Icons.sms_outlined, isDark)),
                      SizedBox(width: 12.r),
                      Expanded(
                        child: _buildDeliveryChip(
                          'whatsapp',
                          'otp_via_whatsapp'.tr(),
                          FontAwesomeIcons.whatsapp,
                          isDark,
                          isWhatsApp: true,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.r),

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
            CustomPhoneField(onChanged: _onPhoneChanged, isDark: isDark, initialCountryCode: 'OM'),
            SizedBox(height: 24.r),
            Text(
              'otp_delivery_method'.tr(),
              style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.r),
            Row(
              children: [
                Expanded(child: _buildDeliveryChip('sms', 'otp_via_sms'.tr(), Icons.sms_outlined, isDark)),
                SizedBox(width: 16.r),
                Expanded(
                  child: _buildDeliveryChip(
                    'whatsapp',
                    'otp_via_whatsapp'.tr(),
                    FontAwesomeIcons.whatsapp,
                    isDark,
                    isWhatsApp: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.r),
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

  Widget _buildDeliveryChip(String method, String label, IconData icon, bool isDark, {bool isWhatsApp = false}) {
    final isSelected = _selectedDeliveryMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 12.r),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isWhatsApp
                ? FaIcon(
                    icon,
                    size: 20.r,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF757575)),
                  )
                : Icon(
                    icon,
                    size: 20.r,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF757575)),
                  ),
            SizedBox(width: 8.r),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.r,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF3D3D3D)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
