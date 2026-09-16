import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/models/common/general_lookup.dart';
import '../../../core/models/vehicle/vehicle_query.dart';
import '../../../core/services/vehicle_filter_options.dart';
import 'lookup_label.dart';

/// Opens the vehicle filter sheet and resolves to the chosen query (or null
/// when dismissed). Only filters the API applies are offered.
Future<VehicleQuery?> showVehicleFilterSheet(
  BuildContext context, {
  required VehicleQuery query,
  required VehicleFilterOptions options,
  bool ar = false,
}) {
  return showModalBottomSheet<VehicleQuery>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VehicleFilterSheet(initial: query, options: options, ar: ar),
  );
}

class _VehicleFilterSheet extends StatefulWidget {
  final VehicleQuery initial;
  final VehicleFilterOptions options;
  final bool ar;

  const _VehicleFilterSheet({required this.initial, required this.options, required this.ar});

  @override
  State<_VehicleFilterSheet> createState() => _VehicleFilterSheetState();
}

class _VehicleFilterSheetState extends State<_VehicleFilterSheet> {
  late VehicleQuery _query = widget.initial;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final o = widget.options;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14141F) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.r),
            Container(
              width: 40.r,
              height: 4.r,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.r, 14.r, 12.r, 4.r),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'search_filters'.tr(),
                      style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                  ),
                  TextButton(
                    // Clears and applies at once — nothing left to choose.
                    onPressed: _query.hasFilters || widget.initial.hasFilters
                        ? () => Navigator.of(context).pop(_query.withoutFilters())
                        : null,
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13.r),
                    ),
                    child: Text('clear_all'.tr()),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(20.r, 4.r, 20.r, 16.r),
                children: [
                  if (o.vehicleTypes.isNotEmpty)
                    _section(
                      'filter_car_type'.tr(),
                      [
                        for (final t in o.vehicleTypes)
                          _chip(generalLookupLabel(t, ar: widget.ar), _query.vehicleTypeId == t.id,
                              () => _toggle(t, _query.vehicleTypeId, _query.withVehicleType)),
                      ],
                    ),
                  if (o.brands.isNotEmpty)
                    _section(
                      'search_filter_brands'.tr(),
                      [
                        for (final b in o.brands)
                          _chip(
                            b.displayName(ar: widget.ar).trim(),
                            _query.brandId == b.id,
                            () => setState(() => _query = _query.withBrand(_query.brandId == b.id ? null : b.id)),
                          ),
                      ],
                    ),
                  if (o.transmissions.isNotEmpty)
                    _section(
                      'filter_transmission'.tr(),
                      [
                        for (final t in o.transmissions)
                          _chip(generalLookupLabel(t, ar: widget.ar), _query.transmissionTypeId == t.id,
                              () => _toggle(t, _query.transmissionTypeId, _query.withTransmission)),
                      ],
                    ),
                  if (o.fuels.isNotEmpty)
                    _section(
                      'filter_fuel'.tr(),
                      [
                        for (final t in o.fuels)
                          _chip(generalLookupLabel(t, ar: widget.ar), _query.fuelTypeId == t.id,
                              () => _toggle(t, _query.fuelTypeId, _query.withFuel)),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.r, 4.r, 20.r, 12.r),
              child: SizedBox(
                width: double.infinity,
                height: 50.r,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_query),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text(
                    'search_apply_filters'.tr(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 15.r,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimary,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(GeneralLookup t, int? current, VehicleQuery Function(int?) apply) {
    setState(() => _query = apply(current == t.id ? null : t.id));
  }

  Widget _section(String title, List<Widget> chips) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: 14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.75)),
          ),
          SizedBox(height: 10.r),
          Wrap(spacing: 8.r, runSpacing: 8.r, children: chips),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return FilterPill(label: label, active: active, onTap: onTap);
  }
}

/// Toggle pill shared by the filter sheet and the quick filter bar.
class FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;
  final int? badge;

  const FilterPill({super.key, required this.label, required this.active, required this.onTap, this.icon, this.badge});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = active ? cs.primary : cs.onSurface.withValues(alpha: 0.7);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 13.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: active
              ? cs.primary.withValues(alpha: isDark ? 0.22 : 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F3F7)),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: active ? cs.primary.withValues(alpha: 0.45) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15.r, color: fg),
              SizedBox(width: 6.r),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 12.5.r, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: fg),
            ),
            if ((badge ?? 0) > 0) ...[
              SizedBox(width: 6.r),
              Container(
                constraints: BoxConstraints(minWidth: 17.r),
                height: 17.r,
                padding: EdgeInsets.symmetric(horizontal: 4.r),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(9.r)),
                child: Text(
                  '$badge',
                  style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: cs.onPrimary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
