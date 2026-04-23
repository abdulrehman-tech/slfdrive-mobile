import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/customer/oman_plate.dart';
import '../data/car_detail_mock_data.dart';
import 'car_glass_card.dart';

/// Card displaying the Oman-style license plate number and code.
class PlateSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const PlateSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDD1F26).withValues(alpha: isDark ? 0.18 : 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Iconsax.card_copy, size: 14.r, color: const Color(0xFFDD1F26)),
                    ),
                    SizedBox(width: 8.r),
                    Text(
                      'car_detail_plate'.tr(),
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                  ],
                ),
                SizedBox(height: 6.r),
                Text(
                  'car_detail_plate_subtitle'.tr(),
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4),
                ),
              ],
            ),
            const Spacer(),
            const OmanPlate(number: kCarDetailPlateNumber, code: kCarDetailPlateCode, width: 150),
          ],
        ),
      ),
    );
  }
}
