import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widgets/skeletons/list_skeleton.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/models/driver/driver_listing_item.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

/// Driver picker shown for "Car + driver" and "Hire driver" when no driver was
/// pre-selected. Loads real drivers from the backend.
class DriverSelectStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const DriverSelectStep({super.key, required this.data, required this.isDark});

  @override
  State<DriverSelectStep> createState() => _DriverSelectStepState();
}

class _DriverSelectStepState extends State<DriverSelectStep> {
  final _repo = getIt<DriverListingRepository>();
  List<DriverListingItem> _drivers = const [];
  bool _loading = false;
  bool _companyScoped = false; // list was filtered to the car's company
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
      // For "Car + driver", scope the list to drivers of the company that owns
      // the chosen car. The vehicle's own `companyId` is authoritative (a branch
      // can hold vehicles from several companies, so branchId is NOT a company
      // key). It matches a driver's `allCompanyId`.
      int? companyId;
      final car = widget.data.car;
      if (widget.data.serviceType == BookingServiceType.carWithDriver) {
        companyId = car?.companyId;
      }

      final page = await _repo.getPaginated(const PaginationParams(pageNumber: 1, pageSize: 50));
      if (!mounted) return;
      var drivers = page.items;
      final scoped = companyId != null;
      if (scoped) {
        // Car + driver → drivers of the car's owning company.
        drivers = drivers.where((d) => d.allCompanyId == companyId).toList();
      } else {
        // Standalone driver hire → freelance drivers only (company-affiliated
        // drivers are booked through their rental company, not directly).
        drivers = drivers.where((d) => d.allCompanyId == null).toList();
      }
      setState(() {
        _drivers = drivers;
        _companyScoped = scoped;
      });
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

  void _select(DriverListingItem d) {
    widget.data.setDriver(BookingDriver(
      // Bookings reference the driver's own id (`driverId`), NOT the response
      // row `id` — sending `id` makes Booking/create 500.
      id: (d.driverId ?? d.id).toString(),
      name: d.displayName(),
      avatarUrl: d.resolvedPhotoUrl ?? '',
      rating: d.rating ?? 0,
      pricePerDay: d.amountPerDay ?? 0,
      pricePerHour: d.amountPerHour ?? 0,
      speciality: d.locationName ?? '',
    ));
  }

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
        if (_loading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40.r),
            child: const ListSkeleton(itemCount: 4, itemHeight: 84, padding: EdgeInsets.zero),
          )
        else if (_error != null)
          _ErrorRetry(message: _error!, onRetry: _load)
        else if (_drivers.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.r),
            child: Center(
              child: Text(
                (_companyScoped ? 'booking_driver_none_for_company' : 'search_no_results').tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13.r),
              ),
            ),
          )
        else
          ..._drivers.map(
            (d) => Padding(
              padding: EdgeInsets.only(bottom: 10.r),
              child: _DriverCard(
                driver: d,
                isSelected: widget.data.driver?.id == (d.driverId ?? d.id).toString(),
                onTap: () => _select(d),
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

class _DriverCard extends StatelessWidget {
  final DriverListingItem driver;
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
    final photo = driver.resolvedPhotoUrl;
    final speciality = driver.locationName ?? '';
    return BookingGlassCard(
      isDark: isDark,
      onTap: onTap,
      borderColor: isSelected ? cs.primary.withValues(alpha: 0.5) : null,
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 2),
              color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
            ),
            clipBehavior: Clip.antiAlias,
            child: photo != null
                ? CachedNetworkImage(
                    imageUrl: photo,
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) => Icon(Iconsax.user_copy, size: 22.r, color: cs.primary),
                  )
                : Icon(Iconsax.user_copy, size: 22.r, color: cs.primary),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.displayName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 4.r),
                if (speciality.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 2.r),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      speciality,
                      style: TextStyle(fontSize: 9.r, color: cs.primary, fontWeight: FontWeight.w700),
                    ),
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
                    (driver.amountPerDay ?? 0).toStringAsFixed(0),
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
