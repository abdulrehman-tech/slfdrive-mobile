import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'provider/brands_provider.dart';
import 'widgets/brand_tile.dart';
import 'widgets/brands_app_bar.dart';
import 'widgets/brands_count_label.dart';
import 'widgets/brands_desktop_header.dart';
import 'widgets/brands_empty_state.dart';
import 'widgets/brands_search_field.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrandsProvider(),
      child: const _BrandsView(),
    );
  }
}

class _BrandsView extends StatefulWidget {
  const _BrandsView();

  @override
  State<_BrandsView> createState() => _BrandsViewState();
}

class _BrandsViewState extends State<_BrandsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode ||
        (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktop() : _buildMobile(),
    );
  }

  Widget _buildMobile() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<BrandsProvider>();
    final brands = provider.filteredBrands;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        BrandsAppBar(isDark: isDark, cs: cs),
        SliverToBoxAdapter(
          child: BrandsSearchField(
            controller: _searchController,
            query: provider.query,
            onChanged: provider.setQuery,
            onClear: () {
              _searchController.clear();
              provider.clearQuery();
            },
            isDark: isDark,
            cs: cs,
            padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 12.r),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.r),
            child: BrandsCountLabel(count: brands.length, cs: cs, fontSize: 12.r),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 32.r),
          sliver: brands.isEmpty
              ? SliverFillRemaining(child: BrandsEmptyState(isDark: isDark, cs: cs))
              : SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.r,
                    mainAxisSpacing: 12.r,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => BrandTile(brand: brands[i], isDark: isDark, cs: cs),
                    childCount: brands.length,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDesktop() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<BrandsProvider>();
    final brands = provider.filteredBrands;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrandsDesktopHeader(
                isDark: isDark,
                cs: cs,
                searchField: BrandsSearchField(
                  controller: _searchController,
                  query: provider.query,
                  onChanged: provider.setQuery,
                  onClear: () {
                    _searchController.clear();
                    provider.clearQuery();
                  },
                  isDark: isDark,
                  cs: cs,
                ),
              ),
              SizedBox(height: 20.r),
              BrandsCountLabel(count: brands.length, cs: cs, fontSize: 13.r),
              SizedBox(height: 16.r),
              brands.isEmpty
                  ? SizedBox(height: 420.r, child: BrandsEmptyState(isDark: isDark, cs: cs))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 16.r,
                        mainAxisSpacing: 16.r,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: brands.length,
                      itemBuilder: (_, i) => BrandTile(brand: brands[i], isDark: isDark, cs: cs),
                    ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }
}
