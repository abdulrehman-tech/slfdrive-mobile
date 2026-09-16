import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../widgets/vehicles/catalog_search_header.dart';
import '../../../widgets/vehicles/vehicle_results_view.dart';
import 'provider/search_provider.dart';
import 'widgets/search_discover.dart';
import 'widgets/search_results_tabs.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ar = context.locale.languageCode == 'ar';
    return ChangeNotifierProvider(
      key: ValueKey(context.locale.languageCode),
      create: (_) {
        final p = SearchProvider(ar: ar);
        WidgetsBinding.instance.addPostFrameCallback((_) => p.focusNode.requestFocus());
        return p;
      },
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SearchProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = VehicleResultsView.sidePadding(constraints.maxWidth);
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(side, 10.r, side, 8.r),
                  child: CatalogSearchHeader(
                    controller: p.searchController,
                    focusNode: p.focusNode,
                    hint: 'search_hint'.tr(),
                    onChanged: p.setText,
                    onSubmitted: p.submit,
                    onClear: p.clearText,
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: p.showDiscover
                        ? SearchDiscover(key: const ValueKey('discover'), side: side)
                        : SearchResultsTabs(key: const ValueKey('results'), side: side),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
