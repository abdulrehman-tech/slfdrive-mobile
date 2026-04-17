import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

class ServiceTypeStep extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const ServiceTypeStep({super.key, required this.data, required this.isDark});

  static const _entries = <(BookingServiceType, IconData, Color)>[
    (BookingServiceType.rentCar, Iconsax.car, Color(0xFF3D5AFE)),
    (BookingServiceType.carWithDriver, Iconsax.driver, Color(0xFF7C4DFF)),
    (BookingServiceType.driverOnly, Iconsax.profile_2user, Color(0xFF00BCD4)),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_service_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_service_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 20.r),
        ..._entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: 14.r),
          child: _ServiceCard(
            type: e.$1,
            icon: e.$2,
            accentColor: e.$3,
            isSelected: data.serviceType == e.$1,
            onTap: () => data.setServiceType(e.$1),
            isDark: isDark,
          ),
        )),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final BookingServiceType type;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ServiceCard({
    required this.type,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BookingGlassCard(
      isDark: isDark,
      onTap: onTap,
      borderColor: isSelected ? accentColor.withValues(alpha: 0.45) : null,
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 54.r,
            height: 54.r,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : accentColor.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: isSelected
                  ? [BoxShadow(color: accentColor.withValues(alpha: 0.35), blurRadius: 14.r, offset: Offset(0, 5.r))]
                  : null,
            ),
            child: Icon(icon, color: isSelected ? Colors.white : accentColor, size: 24.r),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.titleKey.tr(),
                  style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 3.r),
                Text(
                  type.subtitleKey.tr(),
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22.r,
            height: 22.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? accentColor : Colors.transparent,
              border: Border.all(color: isSelected ? accentColor : cs.onSurface.withValues(alpha: 0.2), width: 2),
            ),
            child: isSelected ? Icon(Icons.check, color: Colors.white, size: 14.r) : null,
          ),
        ],
      ),
    );
  }
}
