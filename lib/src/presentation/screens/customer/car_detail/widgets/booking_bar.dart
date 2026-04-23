import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../widgets/omr_icon.dart';
import '../data/car_detail_mock_data.dart';

/// Sticky bottom booking bar shown on mobile with total price + Book button.
class BookingBar extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onBook;

  const BookingBar({
    super.key,
    required this.isDark,
    required this.cs,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 14.r + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 10.r,
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OmrIcon(size: 15.r, color: cs.primary),
                      SizedBox(width: 3.r),
                      Text(
                        kCarDetailPricePerDayLabel,
                        style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.primary),
                      ),
                      Text(
                        'car_detail_per_day'.tr(),
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: onBook,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 14.r),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                        blurRadius: 14.r,
                        offset: Offset(0, 5.r),
                      ),
                    ],
                  ),
                  child: Text(
                    'car_detail_book'.tr(),
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
