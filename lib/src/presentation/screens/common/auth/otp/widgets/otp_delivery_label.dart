import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpDeliveryLabel extends StatelessWidget {
  final String deliveryMethod;
  final String phoneNumber;
  final bool isDark;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final double lineHeight;
  final bool asRichText;

  const OtpDeliveryLabel({
    super.key,
    required this.deliveryMethod,
    required this.phoneNumber,
    required this.isDark,
    required this.iconSize,
    required this.fontSize,
    required this.spacing,
    required this.lineHeight,
    this.asRichText = true,
  });

  @override
  Widget build(BuildContext context) {
    final String methodText = deliveryMethod == 'whatsapp' ? 'otp_sent_via_whatsapp'.tr() : 'otp_sent_via_sms'.tr();
    final Color subtleColor = isDark ? Colors.white70 : const Color(0xFF757575);
    final Color strongColor = isDark ? Colors.white : const Color(0xFF3D3D3D);

    return Row(
      children: [
        Icon(
          deliveryMethod == 'whatsapp' ? Icons.chat_bubble_outline : Icons.sms_outlined,
          size: iconSize,
          color: subtleColor,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: asRichText
              ? RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: fontSize, color: subtleColor, height: lineHeight),
                    children: [
                      TextSpan(text: methodText),
                      TextSpan(
                        text: ' $phoneNumber',
                        style: TextStyle(fontWeight: FontWeight.w600, color: strongColor),
                      ),
                    ],
                  ),
                )
              : Text(
                  '$methodText $phoneNumber',
                  style: TextStyle(fontSize: fontSize, color: subtleColor, height: lineHeight),
                ),
        ),
      ],
    );
  }

  // Helpers so consumers don't need to hardcode .r sizes here.
  static OtpDeliveryLabel mobile({
    required String deliveryMethod,
    required String phoneNumber,
    required bool isDark,
  }) {
    return OtpDeliveryLabel(
      deliveryMethod: deliveryMethod,
      phoneNumber: phoneNumber,
      isDark: isDark,
      iconSize: 18.r,
      fontSize: 16.r,
      spacing: 8.r,
      lineHeight: 1.5,
    );
  }

  static OtpDeliveryLabel desktop({
    required String deliveryMethod,
    required String phoneNumber,
    required bool isDark,
  }) {
    return OtpDeliveryLabel(
      deliveryMethod: deliveryMethod,
      phoneNumber: phoneNumber,
      isDark: isDark,
      iconSize: 20.r,
      fontSize: 18.r,
      spacing: 8.r,
      lineHeight: 1.6,
      asRichText: false,
    );
  }
}
