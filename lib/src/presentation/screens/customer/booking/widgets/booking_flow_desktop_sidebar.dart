import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/booking_step_id.dart';
import 'booking_stepper.dart';

/// Desktop side rail — back button, title, and the vertical step indicator.
class BookingFlowDesktopSidebar extends StatelessWidget {
  final List<BookingStepId> steps;
  final int currentIndex;
  final bool isDark;
  final VoidCallback onBack;
  final ValueChanged<int> onStepTap;

  const BookingFlowDesktopSidebar({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.isDark,
    required this.onBack,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 300.r,
      padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 28.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111118) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                ),
              ),
              SizedBox(width: 12.r),
              Text(
                'booking_title'.tr(),
                style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
            ],
          ),
          SizedBox(height: 28.r),
          BookingStepperVertical(
            steps: steps.map((id) => BookingStep(icon: id.icon, titleKey: id.titleKey)).toList(),
            currentIndex: currentIndex,
            isDark: isDark,
            onStepTap: onStepTap,
          ),
        ],
      ),
    );
  }
}
