import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/icon_constants.dart';
import '../provider/otp_provider.dart';
import 'otp_back_button.dart';
import 'otp_delivery_label.dart';
import 'otp_input_row.dart';
import 'otp_resend_control.dart';
import 'otp_verify_button.dart';

class OtpDesktopLayout extends StatelessWidget {
  final bool isDark;
  final VoidCallback onVerify;

  const OtpDesktopLayout({super.key, required this.isDark, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OtpProvider>();
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
            'otp_title'.tr(),
            style: TextStyle(fontSize: 48.r, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.r),
          OtpDeliveryLabel.desktop(
            deliveryMethod: provider.deliveryMethod,
            phoneNumber: provider.phoneNumber,
            isDark: isDark,
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
            OtpBackButton(isDark: isDark, desktop: true),
            SizedBox(height: 40.r),
            OtpInputRow(isDark: isDark, desktop: true),
            SizedBox(height: 32.r),
            OtpResendControl(isDark: isDark, fontSize: 16.r),
            SizedBox(height: 40.r),
            OtpVerifyButton(isDark: isDark, height: 60.r, onVerify: onVerify),
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
