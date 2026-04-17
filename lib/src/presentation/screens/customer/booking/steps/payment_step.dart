import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

class PaymentStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const PaymentStep({super.key, required this.data, required this.isDark});

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = widget.data;
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_payment_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_payment_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 18.r),

        // Method grid
        _buildMethodGrid(cs, isDark, d),
        SizedBox(height: 14.r),

        // Card entry (only when card is selected)
        if (d.paymentMethod == PaymentMethod.card) _buildCardEntry(cs, isDark),
        if (d.paymentMethod == PaymentMethod.applePay) _buildApplePayHint(cs, isDark),
        if (d.paymentMethod == PaymentMethod.wallet) _buildWalletHint(cs, isDark),
        if (d.paymentMethod == PaymentMethod.cashOnDelivery) _buildCashHint(cs, isDark),

        SizedBox(height: 14.r),
        _buildSecurityNote(cs, isDark),
      ],
    );
  }

  // -----------------------------------------------------------

  Widget _buildMethodGrid(ColorScheme cs, bool isDark, BookingData d) {
    const methods = <(PaymentMethod, IconData, String, Color)>[
      (PaymentMethod.card, Iconsax.card_copy, 'booking_payment_card', Color(0xFF3D5AFE)),
      (PaymentMethod.applePay, Iconsax.mobile_copy, 'booking_payment_apple', Color(0xFF7C4DFF)),
      (PaymentMethod.wallet, Iconsax.wallet_3_copy, 'booking_payment_wallet', Color(0xFF00BCD4)),
      (PaymentMethod.cashOnDelivery, Iconsax.money_copy, 'booking_payment_cash', Color(0xFF4CAF50)),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10.r,
      mainAxisSpacing: 10.r,
      childAspectRatio: 1.6,
      children: methods.map((m) {
        final active = d.paymentMethod == m.$1;
        return GestureDetector(
          onTap: () => d.setPaymentMethod(m.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: active
                  ? m.$4.withValues(alpha: isDark ? 0.2 : 0.12)
                  : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: active
                    ? m.$4.withValues(alpha: 0.45)
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                width: active ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: active ? m.$4 : m.$4.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(m.$2, size: 18.r, color: active ? Colors.white : m.$4),
                ),
                const Spacer(),
                Text(
                  m.$3.tr(),
                  style: TextStyle(
                    fontSize: 12.r,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCardEntry(ColorScheme cs, bool isDark) {
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
            isDark,
            controller: _cardNumberController,
            label: 'booking_payment_card_number'.tr(),
            hint: '0000 0000 0000 0000',
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
                  isDark,
                  controller: _expiryController,
                  label: 'booking_payment_expiry'.tr(),
                  hint: 'MM/YY',
                  keyboard: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()],
                  icon: Iconsax.calendar_copy,
                ),
              ),
              SizedBox(width: 10.r),
              Expanded(
                child: _textField(
                  cs,
                  isDark,
                  controller: _cvvController,
                  label: 'booking_payment_cvv'.tr(),
                  hint: '123',
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
            isDark,
            controller: _nameController,
            label: 'booking_payment_card_name'.tr(),
            hint: 'Full name as on card',
            keyboard: TextInputType.name,
            icon: Iconsax.user_copy,
          ),
        ],
      ),
    );
  }

  Widget _buildApplePayHint(ColorScheme cs, bool isDark) {
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(18.r),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.apple, size: 26.r, color: Colors.white),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'booking_payment_apple_title'.tr(),
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 3.r),
                Text(
                  'booking_payment_apple_desc'.tr(),
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletHint(ColorScheme cs, bool isDark) {
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(18.r),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.wallet_3_copy, size: 22.r, color: const Color(0xFF00BCD4)),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'booking_payment_wallet_title'.tr(),
                      style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                    const Spacer(),
                    OmrIcon(size: 12.r, color: const Color(0xFF00BCD4)),
                    SizedBox(width: 3.r),
                    Text(
                      '42.50',
                      style: TextStyle(
                        fontSize: 14.r,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.r),
                Text(
                  'booking_payment_wallet_desc'.tr(),
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashHint(ColorScheme cs, bool isDark) {
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(18.r),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.money_copy, size: 22.r, color: const Color(0xFF4CAF50)),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'booking_payment_cash_title'.tr(),
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 3.r),
                Text(
                  'booking_payment_cash_desc'.tr(),
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote(ColorScheme cs, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.shield_tick_copy, size: 18.r, color: const Color(0xFF4CAF50)),
          SizedBox(width: 10.r),
          Expanded(
            child: Text(
              'booking_payment_security'.tr(),
              style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.7), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    ColorScheme cs,
    bool isDark, {
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
