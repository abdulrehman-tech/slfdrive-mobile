import 'dart:ui' as ui;

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

class PhoneLoginDesktopLayout extends StatelessWidget {
  final bool isDark;
  final VoidCallback onContinue;

  const PhoneLoginDesktopLayout({super.key, required this.isDark, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final isDriver = context.read<PhoneLoginProvider>().isDriver;
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
            isDriver ? 'driver_phone_title'.tr() : 'phone_title'.tr(),
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
            PhoneLoginBackButton(isDark: isDark, desktop: true),
            SizedBox(height: 40.r),
            PhoneLoginSectionLabel(
              text: 'phone_number'.tr(),
              isDark: isDark,
              fontSize: 16.r,
            ),
            SizedBox(height: 16.r),
            PhoneLoginPhoneInput(isDark: isDark),
            SizedBox(height: 24.r),
            PhoneLoginSectionLabel(
              text: 'otp_delivery_method'.tr(),
              isDark: isDark,
              fontSize: 16.r,
            ),
            SizedBox(height: 16.r),
            PhoneLoginDeliverySelector(isDark: isDark, spacing: 16.r),
            SizedBox(height: 32.r),
            PhoneLoginContinueButton(
              isDark: isDark,
              height: 60.r,
              onContinue: onContinue,
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
}
