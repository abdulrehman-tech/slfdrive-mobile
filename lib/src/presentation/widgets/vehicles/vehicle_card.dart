import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/models/vehicle/vehicle.dart';
import '../../screens/customer/favorites/models/fav_car.dart';
import '../../screens/customer/favorites/provider/favorites_provider.dart';
import '../auth_gate.dart';
import '../omr_icon.dart';
import 'availability_pill.dart';
import 'lookup_label.dart';

/// Row card for vehicle lists (browse cars, search): photo with favourite,
/// then name with its availability status, brand · year · type, the renting
/// company, key specs and the daily price — or "Price on request". Every car
/// is shown; unavailable ones get a dimmed photo and a red status pill.
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final double? rating;
  final bool ar;
  final VoidCallback onTap;

  static const double height = 152;

  const VehicleCard({super.key, required this.vehicle, required this.onTap, this.rating, this.ar = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.r,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
              blurRadius: 14.r,
              offset: Offset(0, 4.r),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Photo(vehicle: vehicle, rating: rating, isDark: isDark, cs: cs),
            Expanded(child: _Info(vehicle: vehicle, rating: rating, ar: ar, isDark: isDark, cs: cs)),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  final Vehicle vehicle;
  final double? rating;
  final bool isDark;
  final ColorScheme cs;

  const _Photo({required this.vehicle, required this.rating, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final id = vehicle.id.toString();
    final isFav = fav.isCarFav(id);
    final fallback = Container(
      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F2F5),
      child: Center(child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.3), size: 28.r)),
    );
    final photo = vehicle.primaryPhoto;
    return SizedBox(
      width: 128.r,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photo == null)
            fallback
          else
            CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              placeholder: (_, _) => fallback,
              errorWidget: (_, _, _) => fallback,
            ),
          // Unavailable cars stay in the list, dimmed.
          if (!vehicle.isAvailable) ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
          PositionedDirectional(
            top: 8.r,
            start: 8.r,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (!await requireLogin(context)) return;
                fav.toggleCar(FavCar(
                  id: id,
                  name: vehicle.displayTitle(),
                  imageUrl: photo ?? '',
                  pricePerDay: vehicle.pricePerDay ?? 0,
                  brand: vehicle.brandName ?? '',
                  rating: rating ?? 0,
                ));
              },
              child: Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  isFav ? Iconsax.heart : Iconsax.heart_copy,
                  size: 15.r,
                  color: isFav ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final Vehicle vehicle;
  final double? rating;
  final bool ar;
  final bool isDark;
  final ColorScheme cs;

  const _Info({required this.vehicle, required this.rating, required this.ar, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final brand = ((ar ? v.brandNameAr : null) ?? v.brandName ?? '').trim();
    final type = lookupLabel(v.vehicleTypeName, nameAr: v.vehicleTypeNameAr, ar: ar);
    final subtitle = [brand, if (v.year != null) '${v.year}', type].where((s) => s.isNotEmpty).join(' · ');
    final company = ((ar ? v.companyNameAr : null) ?? v.companyName ?? '').trim();
    final specs = <(IconData, String)>[
      if ((v.seats ?? 0) > 0) (Iconsax.people_copy, '${v.seats}'),
      if ((v.transmissionTypeName ?? '').isNotEmpty)
        (Iconsax.setting_2_copy, lookupLabel(v.transmissionTypeName, nameAr: v.transmissionTypeNameAr, ar: ar)),
      if ((v.fuelTypeName ?? '').isNotEmpty)
        (Iconsax.gas_station_copy, lookupLabel(v.fuelTypeName, nameAr: v.fuelTypeNameAr, ar: ar)),
    ];

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(12.r, 11.r, 12.r, 11.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  v.displayTitle(ar: ar),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ),
              SizedBox(width: 6.r),
              AvailabilityPill(available: v.isAvailable),
            ],
          ),
          SizedBox(height: 2.r),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.r, color: muted, fontWeight: FontWeight.w500),
            ),
          if (company.isNotEmpty) ...[
            SizedBox(height: 3.r),
            Row(
              children: [
                Icon(Iconsax.building_copy, size: 11.r, color: cs.primary.withValues(alpha: 0.8)),
                SizedBox(width: 4.r),
                Expanded(
                  child: Text(
                    company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.r, color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 7.r),
          // One line; extra pills are clipped rather than wrapping into the price.
          ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  for (final (icon, label) in specs) ...[
                    _Spec(icon: icon, label: label, isDark: isDark, cs: cs),
                    SizedBox(width: 5.r),
                  ],
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(child: _Price(vehicle: v, cs: cs)),
              if (rating != null) ...[
                Icon(Iconsax.star_1_copy, color: const Color(0xFFFFC107), size: 12.r),
                SizedBox(width: 3.r),
                Text(
                  rating!.toStringAsFixed(1),
                  style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w600, color: muted),
                ),
              ] else
                Text(
                  'listing_new'.tr(),
                  style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w600, color: cs.primary.withValues(alpha: 0.8)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Price extends StatelessWidget {
  final Vehicle vehicle;
  final ColorScheme cs;

  const _Price({required this.vehicle, required this.cs});

  @override
  Widget build(BuildContext context) {
    if (!vehicle.hasPrice) {
      return Text(
        'price_on_request'.tr(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.6)),
      );
    }
    final price = vehicle.pricePerDay!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        OmrAmount(
          price == price.roundToDouble() ? price.toInt().toString() : price.toStringAsFixed(1),
          style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w800, color: cs.primary),
        ),
        Text(
          ' / ${'day'.tr()}',
          style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final ColorScheme cs;

  const _Spec({required this.icon, required this.label, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
          SizedBox(width: 3.r),
          Text(label, style: TextStyle(fontSize: 9.5.r, color: cs.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
