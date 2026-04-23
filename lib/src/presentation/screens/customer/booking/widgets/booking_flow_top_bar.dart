import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/booking_step_id.dart';
import 'booking_stepper.dart';

/// Top bar used by the mobile layout — back button + compact step progress.
class BookingFlowTopBar extends StatelessWidget {
  final BookingStepId currentStep;
  final int currentIndex;
  final int totalSteps;
  final bool isDark;
  final VoidCallback onBack;

  const BookingFlowTopBar({
    super.key,
    required this.currentStep,
    required this.currentIndex,
    required this.totalSteps,
    required this.isDark,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, MediaQuery.of(context).padding.top + 8.r, 16.r, 14.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
                ),
              ),
              child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
            ),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: BookingStepperCompact(
              currentIndex: currentIndex,
              totalSteps: totalSteps,
              currentTitle: currentStep.titleKey.tr(),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}
