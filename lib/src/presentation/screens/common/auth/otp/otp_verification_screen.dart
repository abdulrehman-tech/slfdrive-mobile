import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/breakpoints.dart';
import 'provider/otp_provider.dart';
import 'widgets/otp_desktop_layout.dart';
import 'widgets/otp_mobile_layout.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isDriver;
  final String deliveryMethod;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isDriver = false,
    this.deliveryMethod = 'sms',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpProvider(
        phoneNumber: phoneNumber,
        isDriver: isDriver,
        deliveryMethod: deliveryMethod,
      )..requestFirstFocus(),
      child: const _OtpVerificationView(),
    );
  }
}

class _OtpVerificationView extends StatelessWidget {
  const _OtpVerificationView();

  void _onVerify(BuildContext context) {
    final provider = context.read<OtpProvider>();
    if (!provider.isButtonEnabled) return;
    // TODO: Verify OTP with backend
    context.push(
      '/auth/profile-completion',
      extra: {
        'phone': provider.phoneNumber,
        'isDriver': provider.isDriver,
        'otp': provider.otpCode,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
          if (isDesktop) {
            return OtpDesktopLayout(isDark: isDark, onVerify: () => _onVerify(context));
          }
          return OtpMobileLayout(isDark: isDark, onVerify: () => _onVerify(context));
        },
      ),
    );
  }
}
