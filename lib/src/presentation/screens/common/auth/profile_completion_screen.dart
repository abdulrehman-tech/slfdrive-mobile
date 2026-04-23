import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/role_provider.dart';
import 'profile_completion_provider/profile_completion_provider.dart';
import 'profile_completion_widgets/profile_completion_desktop_layout.dart';
import 'profile_completion_widgets/profile_completion_mobile_layout.dart';

/// Entry screen for the profile completion flow (customer or driver).
///
/// This file is intentionally thin: it owns routing, theme detection, and the
/// two date-picker callbacks. All form state lives in
/// [ProfileCompletionProvider]; layout lives in the mobile/desktop layout
/// widgets under `profile_completion_widgets/`.
class ProfileCompletionScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isDriver;

  const ProfileCompletionScreen({super.key, required this.phoneNumber, this.isDriver = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileCompletionProvider(isDriver: isDriver),
      child: _ProfileCompletionView(isDriver: isDriver),
    );
  }
}

class _ProfileCompletionView extends StatelessWidget {
  final bool isDriver;

  const _ProfileCompletionView({required this.isDriver});

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null && context.mounted) {
      context.read<ProfileCompletionProvider>().setDateOfBirth(picked);
    }
  }

  Future<void> _pickLicenseExpiry(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );
    if (picked != null && context.mounted) {
      context.read<ProfileCompletionProvider>().setLicenseExpiry(picked);
    }
  }

  Future<void> _onComplete(BuildContext context) async {
    final provider = context.read<ProfileCompletionProvider>();
    if (!provider.isButtonEnabled) return;
    await context.read<RoleProvider>().setRole(isDriver ? UserRole.driver : UserRole.customer);
    if (!context.mounted) return;
    context.go(isDriver ? '/driver/home' : '/home');
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
            return ProfileCompletionDesktopLayout(
              isDark: isDark,
              isDriver: isDriver,
              onPickDob: _pickDateOfBirth,
              onPickLicenseExpiry: _pickLicenseExpiry,
              onSubmit: () => _onComplete(context),
            );
          }
          return ProfileCompletionMobileLayout(
            isDark: isDark,
            isDriver: isDriver,
            onPickDob: _pickDateOfBirth,
            onPickLicenseExpiry: _pickLicenseExpiry,
            onSubmit: () => _onComplete(context),
          );
        },
      ),
    );
  }
}
