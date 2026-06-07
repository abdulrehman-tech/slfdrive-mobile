import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/breakpoints.dart';
import '../../../../providers/auth_provider.dart';
import 'provider/phone_login_provider.dart';
import 'widgets/phone_login_desktop_layout.dart';
import 'widgets/phone_login_mobile_layout.dart';

class PhoneLoginScreen extends StatelessWidget {
  final bool isDriver;

  const PhoneLoginScreen({super.key, this.isDriver = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhoneLoginProvider(isDriver: isDriver),
      child: const _PhoneLoginView(),
    );
  }
}

class _PhoneLoginView extends StatelessWidget {
  const _PhoneLoginView();

  Future<void> _onContinue(BuildContext context) async {
    final provider = context.read<PhoneLoginProvider>();
    if (!provider.isButtonEnabled || provider.completePhoneNumber.isEmpty) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;

    final session = await auth.sendOtp(
      phoneNumber: provider.completePhoneNumber,
      preferredLang: context.locale.languageCode,
      channel: provider.selectedDeliveryMethod,
    );
    if (!context.mounted) return;

    final userId = session?.user?.id;
    if (session == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Failed to send OTP')),
      );
      return;
    }

    context.push(
      '/auth/otp',
      extra: {
        'phone': provider.completePhoneNumber,
        'isDriver': provider.isDriver,
        'deliveryMethod': provider.selectedDeliveryMethod,
        'userId': userId,
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
            return PhoneLoginDesktopLayout(isDark: isDark, onContinue: () => _onContinue(context));
          }
          return PhoneLoginMobileLayout(isDark: isDark, onContinue: () => _onContinue(context));
        },
      ),
    );
  }
}
