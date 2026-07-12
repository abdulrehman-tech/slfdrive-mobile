import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/data/repositories/delivery_fee_repository.dart';
import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/models/lookup/location_option.dart';
import '../models/booking_data.dart';
import 'pickup_mode_widgets/pickup_delivery_area_section.dart';
import 'pickup_mode_widgets/pickup_delivery_location_section.dart';
import 'pickup_mode_widgets/pickup_delivery_notes_section.dart';
import 'pickup_mode_widgets/pickup_mode_toggle_row.dart';
import 'pickup_mode_widgets/pickup_self_section.dart';

class PickupModeStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const PickupModeStep({super.key, required this.data, required this.isDark});

  @override
  State<PickupModeStep> createState() => _PickupModeStepState();
}

class _PickupModeStepState extends State<PickupModeStep> {
  final _notesController = TextEditingController();
  final DeliveryFeeRepository _deliveryRepo = getIt<DeliveryFeeRepository>();
  final LookupRepository _lookup = getIt<LookupRepository>();

  List<LocationOption> _areas = const [];
  bool _areasLoading = true;
  String? _areasError;

  /// Vehicle's owning company, resolved once (branch → allCompanyId) and reused
  /// for fee lookups.
  int? _companyId;
  bool _companyResolved = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.data.deliveryNotes;
    _loadAreas();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await _lookup.getActiveLocations();
      if (!mounted) return;
      setState(() {
        _areas = areas;
        _areasLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _areasError = e.toString();
        _areasLoading = false;
      });
    }
  }

  Future<int?> _resolveCompanyId() async {
    if (_companyResolved) return _companyId;
    // The vehicle's `companyId` is the DeliveryFee key (verified against the
    // live API: fees are stored per this id). Do NOT derive it from the branch —
    // `GET /Branch/{id}.allCompanyId` returns a DIFFERENT id (e.g. branch 3 →
    // allCompanyId 2) that has no delivery fees, so the lookup came back empty
    // and the fee always showed as "Free". Fall back to the branch only when the
    // vehicle carries no companyId.
    _companyId = widget.data.car?.companyId;
    if (_companyId == null) {
      final branchId = widget.data.car?.branchId;
      if (branchId != null) {
        try {
          _companyId = await _lookup.getBranchCompanyId(branchId);
        } catch (_) {
          _companyId = null;
        }
      }
    }
    _companyResolved = true;
    return _companyId;
  }

  /// On area select: store it, then resolve the (company, area) fee from the
  /// DeliveryFee API. Defaults to 0 (free) when the company has no fee for the
  /// area — the backend still recomputes the authoritative fee on create.
  Future<void> _selectArea(LocationOption area) async {
    widget.data.setDeliveryArea(area);
    final companyId = await _resolveCompanyId();
    if (companyId == null) {
      widget.data.setDeliveryFee(0);
      return;
    }
    widget.data.setDeliveryFeeLoading(true);
    try {
      final fee = await _deliveryRepo.resolveFee(companyId: companyId, locationId: area.id);
      widget.data.setDeliveryFee(fee ?? 0);
    } catch (_) {
      widget.data.setDeliveryFee(0);
    }
  }

  Future<void> _openDeliveryPicker() async {
    final result = await context.pushNamed<BookingLocation?>(
      'booking-location-picker',
      extra: {
        'initial': widget.data.deliveryLocation,
        'forDelivery': true,
      },
    );
    if (result != null) {
      widget.data.setDeliveryLocation(result);
      setState(() {});
      // Resolve the picked point to the nearest serviceable area so the backend
      // can price delivery. The closest area's id becomes the booking locationId.
      _resolveNearestArea(result.latitude, result.longitude);
    }
  }

  /// Maps a picked delivery point to the nearest active area via
  /// `/api/Location/nearest`, then selects it (resolving the fee). If the
  /// nearest area isn't in the loaded dropdown list, it's appended so the
  /// dropdown can reflect the selection.
  Future<void> _resolveNearestArea(double lat, double lon) async {
    widget.data.setDeliveryFeeLoading(true);
    try {
      final nearest = await _lookup.getNearestLocation(lat: lat, lon: lon);
      if (!mounted || nearest == null) {
        widget.data.setDeliveryFeeLoading(false);
        return;
      }
      if (!_areas.any((a) => a.id == nearest.id)) {
        setState(() => _areas = [..._areas, nearest]);
      }
      await _selectArea(nearest);
    } catch (_) {
      widget.data.setDeliveryFeeLoading(false);
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
        PickupModeToggleRow(data: d, isDark: isDark),
        SizedBox(height: 16.r),
        if (d.pickupMode == PickupMode.selfPickup)
          PickupSelfSection(data: d, isDark: isDark),
        if (d.pickupMode == PickupMode.delivery) ...[
          PickupDeliveryLocationSection(
            data: d,
            isDark: isDark,
            onOpenMap: _openDeliveryPicker,
          ),
          SizedBox(height: 14.r),
          PickupDeliveryAreaSection(
            data: d,
            isDark: isDark,
            areas: _areas,
            isLoading: _areasLoading,
            error: _areasError,
            onSelect: _selectArea,
          ),
          SizedBox(height: 14.r),
          PickupDeliveryNotesSection(
            controller: _notesController,
            data: d,
            isDark: isDark,
          ),
        ],
      ],
    );
  }
}
