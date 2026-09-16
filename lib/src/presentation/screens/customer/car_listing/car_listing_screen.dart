import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/vehicle/vehicle_query.dart';
import '../../../providers/vehicle_catalog.dart';
import '../../../widgets/vehicles/catalog_search_header.dart';
import '../../../widgets/vehicles/vehicle_filter_bar.dart';
import '../../../widgets/vehicles/vehicle_results_view.dart';

/// "Browse cars" (home → All Collections, brand tiles, services): every
/// active car, searchable by name and filterable by type, brand, transmission
/// and fuel — all applied by the API — loaded 20 at a time.
class CarListingScreen extends StatefulWidget {
  /// Brand name from a brand tile; resolved to the API's brand id.
  final String? initialBrand;

  const CarListingScreen({super.key, this.initialBrand});

  @override
  State<CarListingScreen> createState() => _CarListingScreenState();
}

class _CarListingScreenState extends State<CarListingScreen> {
  final _search = TextEditingController();
  VehicleCatalog? _catalog;
  String? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Names are localized, so a language switch rebuilds the catalogue.
    final locale = context.locale.languageCode;
    if (locale == _locale) return;
    _locale = locale;
    final previous = _catalog;
    _catalog = VehicleCatalog(ar: locale == 'ar')
      ..start(
        initial: previous?.query ?? VehicleQuery.empty,
        brandName: previous == null ? widget.initialBrand : null,
      );
    if (previous != null) WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
  }

  @override
  void dispose() {
    _catalog?.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog!;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = VehicleResultsView.sidePadding(constraints.maxWidth);
            return VehicleResultsView(
              catalog: catalog,
              onOpen: (v) => context.pushNamed('car-detail', pathParameters: {'id': v.id.toString()}),
              headerSlivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: bg,
                  surfaceTintColor: Colors.transparent,
                  toolbarHeight: 64.r,
                  titleSpacing: side,
                  title: CatalogSearchHeader(
                    controller: _search,
                    hint: 'catalog_search_hint'.tr(),
                    onChanged: catalog.setText,
                    onClear: () {
                      _search.clear();
                      catalog.setText('');
                    },
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(50.r),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.r),
                      child: VehicleFilterBar(
                        catalog: catalog,
                        padding: EdgeInsets.symmetric(horizontal: side),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _TitleRow(catalog: catalog, side: side)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final VehicleCatalog catalog;
  final double side;

  const _TitleRow({required this.catalog, required this.side});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: catalog,
      builder: (context, _) => Padding(
        padding: EdgeInsets.fromLTRB(side, 4.r, side, 12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'car_listing_title'.tr(),
                style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.w800, color: cs.onSurface),
              ),
            ),
            if (!catalog.isLoading && catalog.error == null && catalog.totalCount != null)
              Text(
                'catalog_count'.tr(args: ['${catalog.totalCount}']),
                style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.55)),
              ),
          ],
        ),
      ),
    );
  }
}
