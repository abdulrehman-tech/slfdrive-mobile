import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../widgets/custom_phone_field.dart';
import '../provider/phone_login_provider.dart';

class PhoneLoginPhoneInput extends StatelessWidget {
  final bool isDark;

  const PhoneLoginPhoneInput({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PhoneLoginProvider>();
    return CustomPhoneField(
      onChanged: provider.onPhoneChanged,
      isDark: isDark,
      initialCountryCode: 'OM',
    );
  }
}
