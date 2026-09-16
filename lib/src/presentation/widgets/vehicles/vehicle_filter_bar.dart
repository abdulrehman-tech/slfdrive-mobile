import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../providers/vehicle_catalog.dart';
import 'lookup_label.dart';
import 'vehicle_filter_sheet.dart';

/// One scrollable row of quick filters over a [VehicleCatalog]: the Filters
/// button (with a count), car-type pills, then brand pills. Tapping an active
/// pill clears it.
class VehicleFilterBar extends StatelessWidget {
  final VehicleCatalog catalog;
  final EdgeInsetsGeometry padding;

  const VehicleFilterBar({super.key, required this.catalog, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: catalog,
      builder: (context, _) {
        final q = catalog.query;
        final o = catalog.options;
        final cs = Theme.of(context).colorScheme;
        // Selected brand first so it stays visible without scrolling.
        final brands = [...o.brands]..sort((a, b) => (b.id == q.brandId ? 1 : 0) - (a.id == q.brandId ? 1 : 0));
        return SizedBox(
          height: 38.r,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: padding,
            children: [
              FilterPill(
                icon: Iconsax.setting_4,
                label: 'search_filters'.tr(),
                active: q.hasFilters,
                badge: q.filterCount,
                onTap: () async {
                  final next = await showVehicleFilterSheet(context, query: q, options: o, ar: catalog.ar);
                  if (next != null) catalog.setQuery(next.withText(catalog.query.text));
                },
              ),
              if (o.vehicleTypes.isNotEmpty) ...[
                _gap(),
                for (final t in o.vehicleTypes) ...[
                  FilterPill(
                    label: generalLookupLabel(t, ar: catalog.ar),
                    active: q.vehicleTypeId == t.id,
                    onTap: () => catalog.setQuery(q.withVehicleType(q.vehicleTypeId == t.id ? null : t.id)),
                  ),
                  SizedBox(width: 8.r),
                ],
              ],
              if (brands.isNotEmpty) ...[
                Center(
                  child: Container(width: 1, height: 20.r, color: cs.onSurface.withValues(alpha: 0.12)),
                ),
                _gap(),
                for (final b in brands) ...[
                  FilterPill(
                    label: b.displayName(ar: catalog.ar).trim(),
                    active: q.brandId == b.id,
                    onTap: () => catalog.setQuery(q.withBrand(q.brandId == b.id ? null : b.id)),
                  ),
                  SizedBox(width: 8.r),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _gap() => SizedBox(width: 8.r);
}
