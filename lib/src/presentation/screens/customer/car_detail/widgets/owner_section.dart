import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/car_detail_provider.dart';
import 'car_glass_card.dart';

/// Card showing the car owner avatar and name.
/// Contact actions (phone/WhatsApp) are omitted — the backend DTO
/// does not include owner contact details.
class OwnerSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const OwnerSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<CarDetailProvider>().vehicle;
    if (vehicle == null) return const SizedBox.shrink();

    final ownerName = vehicle.ownerName;
    if (ownerName == null || ownerName.isEmpty) return const SizedBox.shrink();

    final initial = ownerName.isNotEmpty ? ownerName[0].toUpperCase() : '?';

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
                  initial,
                  style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Text(
                ownerName,
                style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
