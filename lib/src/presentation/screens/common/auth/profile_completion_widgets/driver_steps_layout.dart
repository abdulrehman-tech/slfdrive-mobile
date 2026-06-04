import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color_constants.dart';
import '../profile_completion_provider/profile_completion_provider.dart';
import 'driver_additional_info_section.dart';
import 'driver_documents_section.dart';
import 'driver_license_section.dart';
import 'pending_approval_note.dart';
import 'personal_info_section.dart';
import 'profile_avatar_picker.dart';

/// Multi-step driver profile completion. Splits the long form into four short,
/// focused steps with a progress bar and Back/Next/Submit controls, so the
/// driver fills a little at a time instead of scrolling one huge form.
class DriverStepsLayout extends StatelessWidget {
  final bool isDark;
  final Future<void> Function(BuildContext) onPickDob;
  final Future<void> Function(BuildContext) onPickLicenseExpiry;
  final VoidCallback onSubmit;

  const DriverStepsLayout({
    super.key,
    required this.isDark,
    required this.onPickDob,
    required this.onPickLicenseExpiry,
    required this.onSubmit,
  });

  static const List<String> _stepTitleKeys = [
    'profile_step_personal',
    'profile_step_license',
    'profile_step_work',
    'profile_step_documents',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileCompletionProvider>();
    final step = provider.driverStep;
    final total = ProfileCompletionProvider.driverStepCount;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              _topBar(context, provider),
              _progress(step, total),
              SizedBox(height: 8.r),
              _stepLabel(step, total),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.r, 16.r, 24.r, 24.r),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(step),
                      child: _stepBody(step),
                    ),
                  ),
                ),
              ),
              _footer(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, ProfileCompletionProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
      child: Row(
        children: [
          IconButton(
            onPressed: () => provider.isFirstStep ? context.pop() : provider.prevStep(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
              size: 20.r,
            ),
          ),
          Expanded(
            child: Text(
              'driver_profile_title'.tr(),
              style: TextStyle(
                fontSize: 18.r,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(int step, int total) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.r),
      child: Row(
        children: List.generate(total, (i) {
          final done = i <= step;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 6.r,
              margin: EdgeInsetsDirectional.only(end: i == total - 1 ? 0 : 6.r),
              decoration: BoxDecoration(
                color: done ? secondaryColor : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _stepLabel(int step, int total) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.r),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${'step'.tr()} ${step + 1}/$total · ${_stepTitleKeys[step].tr()}',
          style: TextStyle(
            fontSize: 13.r,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _stepBody(int step) {
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Builder(
                builder: (context) {
                  final provider = context.watch<ProfileCompletionProvider>();
                  return ProfileAvatarPicker(
                    picked: provider.avatarPicked,
                    imageBytes: provider.avatarBytes,
                    isDark: isDark,
                    size: 100.r,
                    onTap: provider.pickAvatar,
                  );
                },
              ),
            ),
            SizedBox(height: 24.r),
            PersonalInfoSection(isDark: isDark, onPickDob: onPickDob),
          ],
        );
      case 1:
        return DriverLicenseSection(isDark: isDark, onPickExpiry: onPickLicenseExpiry);
      case 2:
        return DriverAdditionalInfoSection(isDark: isDark);
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DriverDocumentsSection(isDark: isDark),
            SizedBox(height: 20.r),
            PendingApprovalNote(isDark: isDark),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _footer(BuildContext context, ProfileCompletionProvider provider) {
    final step = provider.driverStep;
    final canAdvance = provider.isStepValid(step);
    final isLast = provider.isLastStep;
    final submitting = provider.isSubmitting;
    final primaryEnabled = (isLast ? provider.isButtonEnabled : canAdvance) && !submitting;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 16.r),
      child: Row(
        children: [
          if (!provider.isFirstStep) ...[
            Expanded(
              child: TextButton(
                onPressed: provider.prevStep,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.r),
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text(
                  'back'.tr(),
                  style: TextStyle(
                    fontSize: 15.r,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.r),
          ],
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: primaryEnabled
                  ? (isLast ? onSubmit : provider.nextStep)
                  : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.r),
                backgroundColor: (primaryEnabled || submitting)
                    ? secondaryColor
                    : secondaryColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
              child: submitting
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      isLast ? 'submit_for_approval'.tr() : 'next'.tr(),
                      style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
