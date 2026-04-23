import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../widgets/omr_icon.dart';

/// Bottom action bar shared across mobile + desktop.
///
/// Shows an optional back button, an optional total-price block, and the
/// primary action (Next / Confirm / Pay Now) with a progress spinner while
/// [submitting] is true.
class BookingFlowBottomBar extends StatelessWidget {
  final bool isDark;
  final bool showBack;
  final bool showPrice;
  final bool isLastStep;
  final bool canGoNext;
  final bool submitting;
  final double totalPrice;
  final String nextLabelKey;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const BookingFlowBottomBar({
    super.key,
    required this.isDark,
    required this.showBack,
    required this.showPrice,
    required this.isLastStep,
    required this.canGoNext,
    required this.submitting,
    required this.totalPrice,
    required this.nextLabelKey,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 14.r + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              if (showBack) _buildBackButton(cs),
              if (showPrice) ...[
                if (showBack) SizedBox(width: 14.r),
                Expanded(child: _buildPriceBlock(cs)),
              ] else
                Expanded(child: SizedBox(width: 14.r)),
              _buildPrimaryAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(ColorScheme cs) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(CupertinoIcons.back, size: 19.r, color: cs.onSurface),
      ),
    );
  }

  Widget _buildPriceBlock(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'booking_bar_total'.tr(),
          style: TextStyle(
            fontSize: 10.r,
            color: cs.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.r),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OmrIcon(size: 14.r, color: cs.primary),
            SizedBox(width: 3.r),
            Text(
              totalPrice.toStringAsFixed(2),
              style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w900, color: cs.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryAction() {
    return GestureDetector(
      onTap: canGoNext ? onNext : null,
      child: Opacity(
        opacity: canGoNext ? 1.0 : 0.4,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 16.r),
          decoration: BoxDecoration(
            gradient: primaryGradient,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: canGoNext
                ? [
                    BoxShadow(
                      color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                      blurRadius: 14.r,
                      offset: Offset(0, 5.r),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (submitting)
                SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              else
                Text(
                  nextLabelKey.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              SizedBox(width: 8.r),
              Icon(
                isLastStep ? Iconsax.tick_square_copy : CupertinoIcons.arrow_right,
                size: 15.r,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
