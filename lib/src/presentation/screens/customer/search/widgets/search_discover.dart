import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/vehicles/lookup_label.dart';
import '../../../../widgets/vehicles/vehicle_filter_sheet.dart';
import '../provider/search_provider.dart';

/// What the search screen shows before a query: recent searches, then
/// shortcuts into results by car type and brand, and "See all cars".
class SearchDiscover extends StatelessWidget {
  final double side;

  const SearchDiscover({super.key, required this.side});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SearchProvider>();
    final o = p.cars.options;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(side, 8.r, side, 32.r),
      children: [
        if (p.recent.isNotEmpty) ...[
          _Heading(
            title: 'search_recent'.tr(),
            action: TextButton(
              onPressed: p.clearRecent,
              style: TextButton.styleFrom(textStyle: _buttonText(context)),
              child: Text('clear_all'.tr()),
            ),
          ),
          for (final term in p.recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Iconsax.clock_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.45)),
              title: Text(term, style: TextStyle(fontSize: 14.r, color: cs.onSurface)),
              trailing: IconButton(
                tooltip: 'common_remove'.tr(),
                icon: Icon(Iconsax.close_circle_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.35)),
                onPressed: () => p.removeRecent(term),
              ),
              onTap: () => p.useRecent(term),
            ),
          SizedBox(height: 12.r),
        ] else
          _Intro(cs: cs),
        if (o.vehicleTypes.isNotEmpty) ...[
          _Heading(title: 'search_browse_types'.tr()),
          Wrap(
            spacing: 8.r,
            runSpacing: 8.r,
            children: [
              for (final t in o.vehicleTypes)
                FilterPill(
                  icon: Iconsax.car_copy,
                  label: generalLookupLabel(t, ar: p.ar),
                  active: false,
                  onTap: () => p.browseVehicleType(t.id),
                ),
            ],
          ),
          SizedBox(height: 20.r),
        ],
        if (o.brands.isNotEmpty) ...[
          _Heading(title: 'search_browse_brands'.tr()),
          Wrap(
            spacing: 8.r,
            runSpacing: 8.r,
            children: [
              for (final b in o.brands)
                FilterPill(label: b.displayName(ar: p.ar).trim(), active: false, onTap: () => p.browseBrand(b.id)),
            ],
          ),
          SizedBox(height: 20.r),
        ],
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: p.browseAll,
            style: OutlinedButton.styleFrom(
              textStyle: _buttonText(context),
              padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 12.r),
            ),
            icon: Icon(Iconsax.car_copy, size: 16.r),
            label: Text('search_see_all_cars'.tr()),
          ),
        ),
      ],
    );
  }
}

/// Theme button styles don't carry the app font; pass it explicitly.
TextStyle? _buttonText(BuildContext context) =>
    Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13.r, fontWeight: FontWeight.w600);

class _Heading extends StatelessWidget {
  final String title;
  final Widget? action;

  const _Heading({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.r),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  final ColorScheme cs;

  const _Intro({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.r),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16.r)),
            child: Icon(Iconsax.search_normal_copy, size: 24.r, color: cs.primary),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'search_initial_title'.tr(),
                  style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                SizedBox(height: 3.r),
                Text(
                  'search_initial_subtitle'.tr(),
                  style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
