import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

class PickupModeStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const PickupModeStep({super.key, required this.data, required this.isDark});

  @override
  State<PickupModeStep> createState() => _PickupModeStepState();
}

class _PickupModeStepState extends State<PickupModeStep> {
  final _notesController = TextEditingController();

  static const _savedPickups = <(IconData, String, String)>[
    (Iconsax.house_2, 'Home', 'Al Khuwair, Muscat'),
    (Iconsax.briefcase, 'Work', 'Ruwi High Street, Muscat'),
    (Iconsax.airplane, 'Airport', 'Muscat International Airport'),
  ];

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.data.deliveryNotes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker({required bool isDelivery}) async {
    final result = await context.pushNamed<BookingLocation?>(
      'booking-location-picker',
      extra: {
        'initial': isDelivery ? widget.data.deliveryLocation : widget.data.pickupLocation,
        'forDelivery': isDelivery,
      },
    );
    if (result != null) {
      if (isDelivery) {
        widget.data.setDeliveryLocation(result);
      } else {
        widget.data.setPickupLocation(result);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = widget.isDark;
    final d = widget.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_pickup_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_pickup_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 18.r),

        // Mode toggle
        Row(
          children: [
            Expanded(
              child: _ModeToggle(
                isActive: d.pickupMode == PickupMode.selfPickup,
                icon: Iconsax.shop_copy,
                title: 'booking_pickup_self'.tr(),
                subtitle: 'booking_pickup_self_desc'.tr(),
                color: const Color(0xFF3D5AFE),
                isDark: isDark,
                onTap: () => d.setPickupMode(PickupMode.selfPickup),
              ),
            ),
            SizedBox(width: 10.r),
            Expanded(
              child: _ModeToggle(
                isActive: d.pickupMode == PickupMode.delivery,
                icon: Iconsax.truck_fast_copy,
                title: 'booking_pickup_delivery'.tr(),
                subtitle: 'booking_pickup_delivery_desc'.tr(),
                color: const Color(0xFFE91E63),
                isDark: isDark,
                onTap: () => d.setPickupMode(PickupMode.delivery),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.r),

        if (d.pickupMode == PickupMode.selfPickup) ..._buildSelfPickup(cs, isDark, d),
        if (d.pickupMode == PickupMode.delivery) ..._buildDelivery(cs, isDark, d),
      ],
    );
  }

  List<Widget> _buildSelfPickup(ColorScheme cs, bool isDark, BookingData d) {
    return [
      BookingGlassCard(
        isDark: isDark,
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSectionHeader(
              icon: Iconsax.location_copy,
              iconColor: const Color(0xFF3D5AFE),
              title: 'booking_pickup_point'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            _LocationPreview(
              location: d.pickupLocation,
              fallbackLabel: 'booking_pickup_owner_default'.tr(),
              fallbackAddress: d.car != null ? '${d.car!.brand} — Muscat, Oman' : 'Muscat, Oman',
              isDark: isDark,
              onTap: () => _openMapPicker(isDelivery: false),
            ),
            SizedBox(height: 10.r),
            GestureDetector(
              onTap: () => _openMapPicker(isDelivery: false),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 9.r),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.map_copy, size: 14.r, color: cs.primary),
                    SizedBox(width: 6.r),
                    Text(
                      'booking_pickup_open_map'.tr(),
                      style: TextStyle(fontSize: 12.r, color: cs.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildDelivery(ColorScheme cs, bool isDark, BookingData d) {
    return [
      BookingGlassCard(
        isDark: isDark,
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSectionHeader(
              icon: Iconsax.location_copy,
              iconColor: const Color(0xFFE91E63),
              title: 'booking_delivery_where'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            _LocationPreview(
              location: d.deliveryLocation,
              fallbackLabel: 'booking_delivery_placeholder'.tr(),
              fallbackAddress: 'booking_delivery_placeholder_desc'.tr(),
              isDark: isDark,
              onTap: () => _openMapPicker(isDelivery: true),
            ),
            SizedBox(height: 12.r),
            // Saved addresses quick picker
            Text(
              'booking_delivery_saved'.tr(),
              style: TextStyle(
                fontSize: 11.r,
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.55),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 8.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: _savedPickups
                  .map((e) => GestureDetector(
                        onTap: () => d.setDeliveryLocation(
                          BookingLocation(
                            latitude: 23.5880,
                            longitude: 58.3829,
                            address: e.$3,
                            label: e.$2,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(11.r),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(e.$1, size: 14.r, color: cs.primary),
                              SizedBox(width: 6.r),
                              Text(
                                e.$2,
                                style: TextStyle(
                                  fontSize: 11.r,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 12.r),
            GestureDetector(
              onTap: () => _openMapPicker(isDelivery: true),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 9.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF677EF0)]),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.map_copy, size: 14.r, color: Colors.white),
                    SizedBox(width: 6.r),
                    Text(
                      'booking_delivery_pick_on_map'.tr(),
                      style: TextStyle(fontSize: 12.r, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 14.r),
      BookingGlassCard(
        isDark: isDark,
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSectionHeader(
              icon: Iconsax.note_text_copy,
              iconColor: const Color(0xFF7C4DFF),
              title: 'booking_delivery_notes'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 10.r),
            TextField(
              controller: _notesController,
              maxLines: 3,
              onChanged: d.setDeliveryNotes,
              style: TextStyle(fontSize: 13.r, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'booking_delivery_notes_hint'.tr(),
                hintStyle: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.4)),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(12.r),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ModeToggle({
    required this.isActive,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.45)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: isActive ? color : color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: isActive ? Colors.white : color, size: 18.r),
            ),
            SizedBox(height: 10.r),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.r,
                fontWeight: FontWeight.w700,
                color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
            SizedBox(height: 3.r),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPreview extends StatelessWidget {
  final BookingLocation? location;
  final String fallbackLabel;
  final String fallbackAddress;
  final bool isDark;
  final VoidCallback onTap;

  const _LocationPreview({
    required this.location,
    required this.fallbackLabel,
    required this.fallbackAddress,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasLoc = location != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Iconsax.location_copy, color: cs.primary, size: 20.r),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLoc ? (location!.label ?? 'Selected location') : fallbackLabel,
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    hasLoc ? location!.address : fallbackAddress,
                    style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20.r, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
