import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/color_constants.dart';
import '../provider/otp_provider.dart';

class OtpResendControl extends StatelessWidget {
  final bool isDark;
  final double fontSize;

  const OtpResendControl({super.key, required this.isDark, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OtpProvider>();
    return Center(
      child: provider.resendTimer > 0
          ? Text(
              'resend_in'.tr(args: [provider.resendTimer.toString()]),
              style: TextStyle(fontSize: fontSize, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
            )
          : TextButton(
              onPressed: () {
                final ok = context.read<OtpProvider>().resend();
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('otp_resent'.tr())));
                }
              },
              child: Text(
                'resend_otp'.tr(),
                style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w600, color: secondaryColor),
              ),
            ),
    );
  }
}
