import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Steps used in [BookingStepper].
class BookingStep {
  final IconData icon;
  final String titleKey;

  const BookingStep({required this.icon, required this.titleKey});
}

// Canonical list. The flow controller hides/unhides steps depending on service type.
const kBookingStepsFull = <BookingStep>[
  BookingStep(icon: Iconsax.setting_4_copy, titleKey: 'booking_step_service'),
  BookingStep(icon: Iconsax.calendar_2_copy, titleKey: 'booking_step_dates'),
  BookingStep(icon: Iconsax.truck_copy, titleKey: 'booking_step_pickup'),
  BookingStep(icon: Iconsax.additem_copy, titleKey: 'booking_step_extras'),
  BookingStep(icon: Iconsax.user_octagon_copy, titleKey: 'booking_step_driver'),
  BookingStep(icon: Iconsax.clipboard_text_copy, titleKey: 'booking_step_summary'),
  BookingStep(icon: Iconsax.card_copy, titleKey: 'booking_step_payment'),
];

/// Compact progress bar with step label — used at the top of every mobile step screen.
class BookingStepperCompact extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final String currentTitle;
  final bool isDark;

  const BookingStepperCompact({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.currentTitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = totalSteps == 0 ? 0.0 : (currentIndex + 1) / totalSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'booking_step_label'.tr(namedArgs: {
                'current': '${currentIndex + 1}',
                'total': '$totalSteps',
              }),
              style: TextStyle(
                fontSize: 10.r,
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(width: 8.r),
            Expanded(
              child: Text(
                currentTitle,
                style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.r),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Stack(
            children: [
              Container(
                height: 4.r,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                widthFactor: progress,
                child: Container(
                  height: 4.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0C2485), Color(0xFF677EF0)],
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vertical side-rail stepper — used on desktop.
class BookingStepperVertical extends StatelessWidget {
  final List<BookingStep> steps;
  final int currentIndex;
  final bool isDark;
  final void Function(int)? onStepTap;

  const BookingStepperVertical({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.isDark,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isActive = i == currentIndex;
        final isCompleted = i < currentIndex;
        final color = isActive || isCompleted ? cs.primary : cs.onSurface.withValues(alpha: 0.35);

        return InkWell(
          onTap: isCompleted && onStepTap != null ? () => onStepTap!(i) : null,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: icon + connector
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? cs.primary
                            : (isCompleted
                                ? cs.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                                : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04))),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.35),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 3.r),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isCompleted ? Iconsax.tick_circle_copy : step.icon,
                        size: 16.r,
                        color: isActive ? Colors.white : color,
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2.r,
                        height: 28.r,
                        margin: EdgeInsets.symmetric(vertical: 2.r),
                        color: isCompleted
                            ? cs.primary
                            : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
                      ),
                  ],
                ),
                SizedBox(width: 12.r),
                // Label
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.r),
                    child: Text(
                      step.titleKey.tr(),
                      style: TextStyle(
                        fontSize: 13.r,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
