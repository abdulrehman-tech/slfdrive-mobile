import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widgets/skeletons/list_skeleton.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/models/vehicle/vehicle.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

/// Vehicle picker shown when the service needs a car and none was pre-selected
/// (e.g. the "Car + driver" flow). Loads real vehicles from the backend.
class VehicleSelectStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const VehicleSelectStep({super.key, required this.data, required this.isDark});

  @override
  State<VehicleSelectStep> createState() => _VehicleSelectStepState();
}

class _VehicleSelectStepState extends State<VehicleSelectStep> {
  final _repo = getIt<VehicleRepository>();
  List<Vehicle> _vehicles = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _repo.getPaginated(const PaginationParams(pageNumber: 1, pageSize: 50));
      if (!mounted) return;
      setState(() => _vehicles = page.items);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(Vehicle v) {
    widget.data.setCar(BookingCar(
      id: v.id.toString(),
      name: v.displayTitle(),
      brand: v.brandName ?? '',
      imageUrl: v.primaryPhoto ?? '',
      pricePerDay: v.pricePerDay ?? 0,
      plateNumber: v.plateNumber ?? '',
      lat: v.lat,
      lon: v.lon,
      locationName: v.locationName,
      branchId: v.branchId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_vehicle_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_vehicle_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 18.r),
        if (_loading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40.r),
            child: const ListSkeleton(itemCount: 4, itemHeight: 84, padding: EdgeInsets.zero),
          )
        else if (_error != null)
          _ErrorRetry(message: _error!, onRetry: _load)
        else if (_vehicles.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.r),
            child: Center(
              child: Text(
                'search_no_results'.tr(),
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13.r),
              ),
            ),
          )
        else
          ..._vehicles.map(
            (v) => Padding(
              padding: EdgeInsets.only(bottom: 10.r),
              child: _VehicleCard(
                vehicle: v,
                isSelected: widget.data.car?.id == v.id.toString(),
                onTap: () => _select(v),
                isDark: widget.isDark,
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.r),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: cs.error, fontSize: 13.r)),
          SizedBox(height: 12.r),
          FilledButton(onPressed: onRetry, child: Text('retry'.tr())),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final photo = vehicle.primaryPhoto;
    return BookingGlassCard(
      isDark: isDark,
      onTap: onTap,
      borderColor: isSelected ? cs.primary.withValues(alpha: 0.5) : null,
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          Container(
            width: 76.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: photo != null
                ? CachedNetworkImage(
                    imageUrl: photo,
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) => Icon(Iconsax.car_copy, size: 24.r, color: cs.primary),
                  )
                : Icon(Iconsax.car_copy, size: 24.r, color: cs.primary),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.displayTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 4.r),
                Row(
                  children: [
                    OmrIcon(size: 12.r, color: cs.primary),
                    SizedBox(width: 3.r),
                    Text(
                      (vehicle.pricePerDay ?? 0).toStringAsFixed(0),
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: cs.primary),
                    ),
                    SizedBox(width: 3.r),
                    Text(
                      'booking_per_day'.tr(),
                      style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    );
  }
}
