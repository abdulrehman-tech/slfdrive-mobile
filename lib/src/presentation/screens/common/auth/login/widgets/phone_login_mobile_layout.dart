import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/icon_constants.dart';
import '../provider/phone_login_provider.dart';
import 'phone_login_back_button.dart';
import 'phone_login_continue_button.dart';
import 'phone_login_delivery_selector.dart';
import 'phone_login_phone_input.dart';
import 'phone_login_section_label.dart';

class PhoneLoginMobileLayout extends StatelessWidget {
  final bool isDark;
  final VoidCallback onContinue;

  const PhoneLoginMobileLayout({super.key, required this.isDark, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final isDriver = context.read<PhoneLoginProvider>().isDriver;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
            child: Row(
              children: [PhoneLoginBackButton(isDark: isDark)],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.r),
                  Center(
                    child: SvgPicture.asset(
                      isDark ? IconConstants.logoWhite : IconConstants.logo,
                      width: 120.r,
                      height: 120.r,
                    ),
                  ),
                  SizedBox(height: 40.r),
                  Text(
                    isDriver ? 'driver_phone_title'.tr() : 'phone_title'.tr(),
                    style: TextStyle(
                      fontSize: 28.r,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),
                  SizedBox(height: 12.r),
                  Text(
                    'phone_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 16.r,
                      color: isDark ? Colors.white70 : const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 40.r),
                  PhoneLoginSectionLabel(
                    text: 'phone_number'.tr(),
                    isDark: isDark,
                    fontSize: 14.r,
                  ),
                  SizedBox(height: 12.r),
                  PhoneLoginPhoneInput(isDark: isDark),
                  SizedBox(height: 24.r),
                  PhoneLoginSectionLabel(
                    text: 'otp_delivery_method'.tr(),
                    isDark: isDark,
                    fontSize: 14.r,
                  ),
                  SizedBox(height: 12.r),
                  PhoneLoginDeliverySelector(isDark: isDark, spacing: 12.r),
                  SizedBox(height: 32.r),
                  PhoneLoginContinueButton(
                    isDark: isDark,
                    height: 56.r,
                    onContinue: onContinue,
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
}
