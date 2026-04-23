import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../providers/role_provider.dart';

/// "Skip & explore" grants a guest customer session so the role guard lets
/// the user into `/home` without completing OTP. Signed-up customers overwrite
/// this in the profile-completion step.
Future<void> _continueAsGuest(BuildContext context) async {
  await context.read<RoleProvider>().setRole(UserRole.customer);
  if (context.mounted) context.go('/home');
}

/// Bottom row with "Skip" (guest entry) on the leading side and "Sign in"
/// on the trailing side. Shared between mobile/desktop with a font size knob.
class PreLoginFooterActions extends StatelessWidget {
  final double fontSize;
  final EdgeInsetsGeometry? buttonPadding;

  const PreLoginFooterActions({super.key, required this.fontSize, this.buttonPadding});

  @override
  Widget build(BuildContext context) {
    final skipStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
      decoration: TextDecoration.underline,
      decorationColor: Colors.white70,
    );
    final signInStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      decoration: TextDecoration.underline,
      decorationColor: Colors.white,
    );
    final style = buttonPadding != null
        ? TextButton.styleFrom(padding: buttonPadding)
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => _continueAsGuest(context),
          style: style,
          child: Text('skip'.tr(), style: skipStyle),
        ),
        TextButton(
          onPressed: () => context.push('/auth/phone', extra: {'isDriver': false}),
          style: style,
          child: Text('sign_in'.tr(), style: signInStyle),
        ),
      ],
    );
  }

  /// Mobile preset: 15pt with tight 4r/8r padding.
  factory PreLoginFooterActions.mobile({Key? key}) {
    return PreLoginFooterActions(
      key: key,
      fontSize: 15.r,
      buttonPadding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 8.r),
    );
  }

  /// Desktop preset: 16pt with default TextButton padding.
  factory PreLoginFooterActions.desktop({Key? key}) {
    return PreLoginFooterActions(key: key, fontSize: 16.r);
  }
}
