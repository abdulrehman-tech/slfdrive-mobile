import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/phone_login_provider.dart';

class PhoneLoginContinueButton extends StatelessWidget {
  final bool isDark;
  final double height;
  final VoidCallback onContinue;

  const PhoneLoginContinueButton({
    super.key,
    required this.isDark,
    required this.height,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<PhoneLoginProvider>().isButtonEnabled;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: enabled ? null : (isDark ? Colors.grey[800] : const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onContinue : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              'continue'.tr(),
              style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
