import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../widgets/booking_glass_card.dart';

class PaymentCardForm extends StatelessWidget {
  final bool isDark;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController nameController;

  const PaymentCardForm({
    super.key,
    required this.isDark,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.card_copy,
            iconColor: const Color(0xFF3D5AFE),
            title: 'booking_payment_card_info'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 14.r),
          _textField(
            cs,
            controller: cardNumberController,
            label: 'booking_payment_card_number'.tr(),
            hint: 'payment_card_number_hint'.tr(),
            keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly, _CardFormatter()],
            icon: Iconsax.card_copy,
          ),
          SizedBox(height: 10.r),
          Row(
            children: [
              Expanded(
                child: _textField(
                  cs,
                  controller: expiryController,
                  label: 'booking_payment_expiry'.tr(),
                  hint: 'payment_card_expiry_hint'.tr(),
                  keyboard: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()],
                  icon: Iconsax.calendar_copy,
                ),
              ),
              SizedBox(width: 10.r),
              Expanded(
                child: _textField(
                  cs,
                  controller: cvvController,
                  label: 'booking_payment_cvv'.tr(),
                  hint: 'payment_card_cvv_hint'.tr(),
                  keyboard: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  icon: Iconsax.password_check_copy,
                  obscure: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.r),
          _textField(
            cs,
            controller: nameController,
            label: 'booking_payment_card_name'.tr(),
            hint: 'payment_card_name_hint'.tr(),
            keyboard: TextInputType.name,
            icon: Iconsax.user_copy,
          ),
        ],
      ),
    );
  }

  Widget _textField(
    ColorScheme cs, {
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    IconData? icon,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.r,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: 5.r),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: formatters,
          obscureText: obscure,
          style: TextStyle(fontSize: 13.r, color: cs.onSurface, letterSpacing: 0.4),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.35)),
            prefixIcon: icon != null ? Icon(icon, size: 16.r, color: cs.onSurface.withValues(alpha: 0.4)) : null,
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 10.r),
          ),
        ),
      ],
    );
  }
}

class _CardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 4 ? digits.substring(0, 4) : digits;
    String formatted;
    if (limited.length >= 3) {
      formatted = '${limited.substring(0, 2)}/${limited.substring(2)}';
    } else {
      formatted = limited;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
