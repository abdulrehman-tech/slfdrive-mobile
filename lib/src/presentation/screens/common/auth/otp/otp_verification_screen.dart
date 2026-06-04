import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/breakpoints.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/role_provider.dart';
import 'provider/otp_provider.dart';
import 'widgets/otp_desktop_layout.dart';
import 'widgets/otp_mobile_layout.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isDriver;
  final String deliveryMethod;
  final int userId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isDriver = false,
    this.deliveryMethod = 'sms',
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => OtpProvider(
        phoneNumber: phoneNumber,
        isDriver: isDriver,
        deliveryMethod: deliveryMethod,
        userId: userId,
      )
        ..requestFirstFocus()
        ..onResend = (() async {
          await ctx.read<AuthProvider>().sendOtp(
                phoneNumber: phoneNumber,
                preferredLang: ctx.locale.languageCode,
              );
        }),
      child: const _OtpVerificationView(),
    );
  }
}

class _OtpVerificationView extends StatelessWidget {
  const _OtpVerificationView();

  Future<void> _onVerify(BuildContext context) async {
    final provider = context.read<OtpProvider>();
    if (!provider.isButtonEnabled) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;

    final user = await auth.verifyOtp(userId: provider.userId, otpCode: provider.otpCode);
    if (!context.mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'OTP verification failed')),
      );
      return;
    }

    // A brand-new account is seeded by the backend with the placeholder name
    // "default" (and empty role). Detect that — or a blank name — and send it
    // to profile completion. The role for a new account comes from the flow the
    // user picked (isDriver: driver vs passenger/login → customer); for an
    // existing account we trust the role the server returned.
    final name = (user.fullName ?? '').trim().toLowerCase();
    final needsProfile = name.isEmpty || name == 'default';
    if (needsProfile) {
      context.push(
        '/auth/profile-completion',
        extra: {
          'phone': provider.phoneNumber,
          'isDriver': provider.isDriver,
          'userId': provider.userId,
        },
      );
      return;
    }

    await context.read<RoleProvider>().setRole(
          user.isDriver ? UserRole.driver : UserRole.customer,
        );
    if (!context.mounted) return;

    context.go(user.isDriver ? '/driver/home' : '/home');
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
