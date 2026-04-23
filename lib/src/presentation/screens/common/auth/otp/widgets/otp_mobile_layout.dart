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

class OtpMobileLayout extends StatelessWidget {
  final bool isDark;
  final VoidCallback onVerify;

  const OtpMobileLayout({super.key, required this.isDark, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OtpProvider>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
            child: Row(
              children: [OtpBackButton(isDark: isDark)],
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
                    'otp_title'.tr(),
                    style: TextStyle(
                      fontSize: 28.r,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),
                  SizedBox(height: 12.r),
                  OtpDeliveryLabel.mobile(
                    deliveryMethod: provider.deliveryMethod,
                    phoneNumber: provider.phoneNumber,
                    isDark: isDark,
                  ),
                  SizedBox(height: 40.r),
                  OtpInputRow(isDark: isDark),
                  SizedBox(height: 32.r),
                  OtpResendControl(isDark: isDark, fontSize: 14.r),
                  SizedBox(height: 40.r),
                  OtpVerifyButton(isDark: isDark, height: 56.r, onVerify: onVerify),
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
