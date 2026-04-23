import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BookingCancelButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const BookingCancelButton({super.key, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.r),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.close_circle_copy, size: 16.r, color: const Color(0xFFE53935)),
            SizedBox(width: 6.r),
            Text(
              'booking_detail_cancel'.tr(),
              style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: const Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }
}
