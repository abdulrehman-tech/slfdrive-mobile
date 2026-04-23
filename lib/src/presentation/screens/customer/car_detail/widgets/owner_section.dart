import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../utils/contact_launcher.dart';
import '../data/car_detail_mock_data.dart';
import 'car_glass_card.dart';

/// Card showing the car owner avatar, name, stats, and contact actions.
class OwnerSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const OwnerSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)]),
              ),
              child: Center(
                child: Text(
                  kCarDetailOwnerInitial,
                  style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kCarDetailOwnerName,
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  SizedBox(height: 2.r),
                  Row(
                    children: [
                      Icon(Iconsax.star_1_copy, size: 12.r, color: const Color(0xFFFFC107)),
                      SizedBox(width: 3.r),
                      Text(
                        kCarDetailOwnerStats,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ContactLauncher.openWhatsApp(
                kCarDetailOwnerPhone,
                message: kCarDetailOwnerWhatsAppMessage,
              ),
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Iconsax.message_copy, size: 16.r, color: const Color(0xFF25D366)),
              ),
            ),
            SizedBox(width: 8.r),
            GestureDetector(
              onTap: () => ContactLauncher.openPhoneCall(kCarDetailOwnerPhone),
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Iconsax.call_copy, size: 16.r, color: cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
