import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../core/data/repositories/lookup_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/role_provider.dart';
import 'profile_completion_provider/profile_completion_provider.dart';
import 'profile_completion_widgets/driver_steps_layout.dart';
import 'profile_completion_widgets/profile_completion_desktop_layout.dart';
import 'profile_completion_widgets/profile_completion_mobile_layout.dart';

/// Entry screen for the profile completion flow (customer or driver).
///
/// This file is intentionally thin: it owns routing, theme detection, the two
/// date-picker callbacks, and the submit handler. All form state lives in
/// [ProfileCompletionProvider]; the API call goes through the global
/// [AuthProvider]; layout lives in the mobile/desktop layout widgets under
/// `profile_completion_widgets/`.
class ProfileCompletionScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isDriver;
  final int userId;

  const ProfileCompletionScreen({
    super.key,
    required this.phoneNumber,
    required this.userId,
    this.isDriver = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileCompletionProvider(
        userId: userId,
        isDriver: isDriver,
        lookupRepository: getIt<LookupRepository>(),
      ),
      child: _ProfileCompletionView(isDriver: isDriver),
    );
  }
}

class _ProfileCompletionView extends StatelessWidget {
  final bool isDriver;

  const _ProfileCompletionView({required this.isDriver});

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final eighteenYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 18));
    final picked = await _showCupertinoDatePicker(
      context,
      initial: DateTime(1990, 1, 1),
      minimum: DateTime(1950),
      maximum: eighteenYearsAgo,
    );
    if (picked != null && context.mounted) {
      context.read<ProfileCompletionProvider>().setDateOfBirth(picked);
    }
  }

  Future<void> _pickLicenseExpiry(BuildContext context) async {
    final now = DateTime.now();
    final picked = await _showCupertinoDatePicker(
      context,
      initial: now.add(const Duration(days: 365)),
      minimum: now,
      maximum: DateTime(2040),
    );
    if (picked != null && context.mounted) {
      context.read<ProfileCompletionProvider>().setLicenseExpiry(picked);
    }
  }

  /// Bottom-sheet Cupertino date picker with a Cancel / Done bar. Returns the
  /// chosen date, or null if dismissed/cancelled.
  Future<DateTime?> _showCupertinoDatePicker(
    BuildContext context, {
    required DateTime initial,
    required DateTime minimum,
    required DateTime maximum,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var selected = initial;
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: 320.r,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text('cancel'.tr()),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                      child: Text('done'.tr()),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: minimum,
                    maximumDate: maximum,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onComplete(BuildContext context) async {
    final provider = context.read<ProfileCompletionProvider>();
    if (!provider.isButtonEnabled || provider.isSubmitting) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;

    final preferredLang = context.locale.languageCode;

    // Show the spinner for the whole submit (location capture + upload).
    provider.setSubmitting(true);

    // Best-effort location capture (prompts for permission). Never blocks
    // submission — lat/lon stay null if the user denies.
    await provider.captureLocation();

    final fullName = provider.nameController.text.trim();
    final fullNameAr = provider.nameArController.text.trim();
    final email = provider.emailController.text.trim();
    final gender = provider.genderCode;
    final dob = provider.dateOfBirthIso ?? '';

    final result = isDriver
        ? await auth.completeDriverProfile(
            userId: provider.userId,
            fullName: fullName,
            fullNameAr: fullNameAr,
            email: email,
            gender: gender,
            preferredLang: preferredLang,
            dateOfBirthIso: dob,
            licenceNumber: provider.licenseNumberController.text.trim(),
            carPlateNumber: provider.carPlateController.text.trim(),
            licenceExpiryIso: provider.licenseExpiryIso ?? '',
            locationId: provider.selectedLocationId,
            hasVehicle: provider.hasVehicle,
            languagesKnown: provider.languagesKnownCsv,
            yearsOfExperience: provider.yearsOfExperience,
            amountPerDay: provider.amountPerDay,
            amountPerHour: provider.amountPerHour,
            photo: provider.avatar,
            civilIdFront: provider.civilIdFront,
            civilIdBack: provider.civilIdBack,
            drivingLicenseFront: provider.drivingLicenseFront,
            drivingLicenseBack: provider.drivingLicenseBack,
            medicalReport: provider.medicalCertificate,
            lat: provider.lat,
            lon: provider.lon,
          )
        : await auth.completeIndividualProfile(
            userId: provider.userId,
            fullName: fullName,
            fullNameAr: fullNameAr,
            email: email,
            gender: gender,
            preferredLang: preferredLang,
            dateOfBirthIso: dob,
            photo: provider.avatar,
            lat: provider.lat,
            lon: provider.lon,
          );

    if (!context.mounted) return;

    if (result == null) {
      provider.setSubmitting(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'profile_completion_failed'.tr())),
      );
      return;
    }

    // On success we navigate away and the screen (and provider) is disposed, so
    // we deliberately leave the spinner up rather than touch the disposed
    // provider.
    await context.read<RoleProvider>().setRole(isDriver ? UserRole.driver : UserRole.customer);
    if (!context.mounted) return;
    context.go(isDriver ? '/driver/home' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      // Drivers get a short, guided multi-step wizard; customers keep the quick
      // single-page form (it only has a handful of fields).
      body: isDriver
          ? DriverStepsLayout(
              isDark: isDark,
              onPickDob: _pickDateOfBirth,
              onPickLicenseExpiry: _pickLicenseExpiry,
              onSubmit: () => _onComplete(context),
            )
          : LayoutBuilder(
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
