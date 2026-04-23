import 'package:flutter/material.dart';
import '../../../../constants/breakpoints.dart';
import 'pre_login_widgets/pre_login_desktop_layout.dart';
import 'pre_login_widgets/pre_login_mobile_layout.dart';

/// Entry point shown before any auth — picks passenger/driver, offers guest
/// "skip" and "sign in" shortcuts. Purely presentational; no local state, so
/// no provider is needed. Routing owns the `context.push('/auth/phone', ...)`
/// transitions.
class PreLoginScreen extends StatelessWidget {
  const PreLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (Breakpoints.isDesktop(constraints.maxWidth)) {
            return const PreLoginDesktopLayout();
          }
          return const PreLoginMobileLayout();
        },
      ),
    );
  }
}
