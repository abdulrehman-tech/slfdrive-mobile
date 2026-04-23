import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/booking_data.dart';
import 'payment_widgets/payment_apple_hint.dart';
import 'payment_widgets/payment_card_form.dart';
import 'payment_widgets/payment_cash_hint.dart';
import 'payment_widgets/payment_header.dart';
import 'payment_widgets/payment_method_grid.dart';
import 'payment_widgets/payment_security_note.dart';
import 'payment_widgets/payment_wallet_hint.dart';

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
    final d = widget.data;
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PaymentHeader(),
        SizedBox(height: 18.r),

        // Method grid
        PaymentMethodGrid(data: d, isDark: isDark),
        SizedBox(height: 14.r),

        // Method-specific detail card
        if (d.paymentMethod == PaymentMethod.card)
          PaymentCardForm(
            isDark: isDark,
            cardNumberController: _cardNumberController,
            expiryController: _expiryController,
            cvvController: _cvvController,
            nameController: _nameController,
          ),
        if (d.paymentMethod == PaymentMethod.applePay) PaymentAppleHint(isDark: isDark),
        if (d.paymentMethod == PaymentMethod.wallet) PaymentWalletHint(isDark: isDark),
        if (d.paymentMethod == PaymentMethod.cashOnDelivery) PaymentCashHint(isDark: isDark),

        SizedBox(height: 14.r),
        PaymentSecurityNote(isDark: isDark),
      ],
    );
  }
}
