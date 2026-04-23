import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'phone_login_delivery_chip.dart';

class PhoneLoginDeliverySelector extends StatelessWidget {
  final bool isDark;
  final double spacing;

  const PhoneLoginDeliverySelector({super.key, required this.isDark, required this.spacing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PhoneLoginDeliveryChip(
            method: 'sms',
            label: 'otp_via_sms'.tr(),
            icon: Icons.sms_outlined,
            isDark: isDark,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: PhoneLoginDeliveryChip(
            method: 'whatsapp',
            label: 'otp_via_whatsapp'.tr(),
            icon: FontAwesomeIcons.whatsapp,
            isDark: isDark,
            isWhatsApp: true,
          ),
        ),
      ],
    );
  }
}
