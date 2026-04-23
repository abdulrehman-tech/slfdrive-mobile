import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

class ExtrasStep extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const ExtrasStep({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selected = data.selectedExtras;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_extras_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_extras_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 18.r),
        ...kBookingExtras.map((e) {
          final isSelected = selected.contains(e.id);
          return Padding(
            padding: EdgeInsets.only(bottom: 10.r),
            child: _ExtraTile(extra: e, isSelected: isSelected, isDark: isDark, onTap: () => data.toggleExtra(e.id)),
          );
        }),
        SizedBox(height: 4.r),
        BookingGlassCard(
          isDark: isDark,
          padding: EdgeInsets.all(14.r),
          child: Row(
            children: [
              Icon(Iconsax.info_circle_copy, size: 18.r, color: cs.primary),
              SizedBox(width: 10.r),
              Expanded(
                child: Text(
                  'booking_extras_hint'.tr(),
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.6), height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExtraTile extends StatelessWidget {
  final BookingExtra extra;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ExtraTile({
    required this.extra,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  IconData get _iconData {
    switch (extra.iconKey) {
      case 'safety':
        return Iconsax.security_safe_copy;
      case 'map':
        return Iconsax.map_1_copy;
      case 'user':
        return Iconsax.user_add_copy;
      case 'shield':
        return Iconsax.shield_tick_copy;
      case 'airplane':
        return Iconsax.airplane_copy;
      case 'fuel':
        return Iconsax.gas_station_copy;
      default:
        return Iconsax.additem_copy;
    }
  }

  Color get _color {
    switch (extra.iconKey) {
      case 'safety':
        return const Color(0xFF4CAF50);
      case 'map':
        return const Color(0xFF3D5AFE);
      case 'user':
        return const Color(0xFF7C4DFF);
      case 'shield':
        return const Color(0xFF00BCD4);
      case 'airplane':
        return const Color(0xFFE91E63);
      case 'fuel':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BookingGlassCard(
      isDark: isDark,
      onTap: onTap,
      borderColor: isSelected ? _color.withValues(alpha: 0.45) : null,
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: isSelected ? _color : _color.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(_iconData, color: isSelected ? Colors.white : _color, size: 20.r),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  extra.titleKey.tr(),
                  style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 2.r),
                Text(
                  extra.subtitleKey.tr(),
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.35),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.r),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OmrIcon(size: 12.r, color: _color),
                  SizedBox(width: 3.r),
                  Text(
                    extra.pricePerDay.toStringAsFixed(0),
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: _color),
                  ),
                ],
              ),
              SizedBox(height: 2.r),
              Text(
                'booking_per_day'.tr(),
                style: TextStyle(fontSize: 9.r, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
              SizedBox(height: 6.r),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _color : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _color : cs.onSurface.withValues(alpha: 0.2),
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
