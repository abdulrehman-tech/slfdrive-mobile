import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

/// Driver picker used when service type is "Car + Driver".
/// Mocks a filtered list of available drivers for the selected dates.
class DriverSelectStep extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const DriverSelectStep({super.key, required this.data, required this.isDark});

  static const _pool = <BookingDriver>[
    BookingDriver(
      id: 'd1',
      name: 'Ahmed Al-Farsi',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      rating: 4.9,
      pricePerDay: 40,
      speciality: 'Chauffeur',
    ),
    BookingDriver(
      id: 'd2',
      name: 'Mohammed K.',
      avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
      rating: 4.8,
      pricePerDay: 35,
      speciality: 'Airport',
    ),
    BookingDriver(
      id: 'd3',
      name: 'Yusuf Hassan',
      avatarUrl: 'https://randomuser.me/api/portraits/men/61.jpg',
      rating: 4.7,
      pricePerDay: 32,
      speciality: 'City Tours',
    ),
    BookingDriver(
      id: 'd4',
      name: 'Omar Saeed',
      avatarUrl: 'https://randomuser.me/api/portraits/men/77.jpg',
      rating: 4.9,
      pricePerDay: 42,
      speciality: 'Long Trips',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_driver_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_driver_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 18.r),
        ..._pool.map(
          (d) => Padding(
            padding: EdgeInsets.only(bottom: 10.r),
            child: _DriverCard(
              driver: d,
              isSelected: data.driver?.id == d.id,
              onTap: () => data.setDriver(d),
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  final BookingDriver driver;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DriverCard({
    required this.driver,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BookingGlassCard(
      isDark: isDark,
      onTap: onTap,
      borderColor: isSelected ? cs.primary.withValues(alpha: 0.5) : null,
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CachedNetworkImage(
                imageUrl: driver.avatarUrl,
                imageBuilder: (_, img) => Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 2),
                    image: DecorationImage(image: img, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (_, _) => CircleAvatar(
                  radius: 28.r,
                  backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                ),
                errorWidget: (_, _, _) => CircleAvatar(
                  radius: 28.r,
                  backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                  child: Icon(Iconsax.user_copy, size: 22.r, color: cs.primary),
                ),
              ),
              Container(
                width: 14.r,
                height: 14.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? const Color(0xFF1A1A28) : Colors.white, width: 2),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 4.r),
                Row(
                  children: [
                    Icon(Iconsax.star_1_copy, size: 13.r, color: const Color(0xFFFFC107)),
                    SizedBox(width: 3.r),
                    Text(
                      driver.rating.toString(),
                      style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                    SizedBox(width: 8.r),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 2.r),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        driver.speciality,
                        style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OmrIcon(size: 12.r, color: cs.primary),
                  SizedBox(width: 3.r),
                  Text(
                    driver.pricePerDay.toStringAsFixed(0),
                    style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w800, color: cs.primary),
                  ),
                ],
              ),
              SizedBox(height: 2.r),
              Text(
                'booking_per_day'.tr(),
                style: TextStyle(fontSize: 9.r, color: cs.onSurface.withValues(alpha: 0.45)),
              ),
              SizedBox(height: 6.r),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? cs.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: isSelected ? Icon(Icons.check, color: Colors.white, size: 13.r) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
