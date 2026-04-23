import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../data/search_mock_data.dart';
import '../provider/search_provider.dart';

typedef FilterApplyCallback = void Function(
  int type,
  int duration,
  RangeValues price,
  Set<String> brands,
  double rating,
);

class FilterBottomSheet extends StatefulWidget {
  final bool isDark;
  final ColorScheme cs;
  final int typeFilter;
  final int durationFilter;
  final RangeValues priceRange;
  final Set<String> selectedBrands;
  final double minRating;
  final FilterApplyCallback onApply;

  const FilterBottomSheet({
    super.key,
    required this.isDark,
    required this.cs,
    required this.typeFilter,
    required this.durationFilter,
    required this.priceRange,
    required this.selectedBrands,
    required this.minRating,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late int _type;
  late int _duration;
  late RangeValues _price;
  late Set<String> _brands;
  late double _rating;

  static const _typeLabels = ['search_filter_all', 'search_filter_cars', 'search_filter_drivers'];
  static const _typeIcons = [Iconsax.search_normal_copy, Iconsax.car_copy, Iconsax.profile_2user_copy];
  static const _durationLabels = [
    'search_filter_daily',
    'search_filter_weekly',
    'search_filter_monthly',
    'search_filter_yearly',
  ];
  static const _durationIcons = [Iconsax.calendar_1, Iconsax.calendar, Iconsax.calendar_tick, Iconsax.calendar_2];

  @override
  void initState() {
    super.initState();
    _type = widget.typeFilter;
    _duration = widget.durationFilter;
    _price = widget.priceRange;
    _brands = Set.from(widget.selectedBrands);
    _rating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cs = widget.cs;

    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14142A).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12.r),
                child: Container(
                  width: 36.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 4.r),
                child: Row(
                  children: [
                    Icon(Iconsax.setting_4, size: 20.r, color: cs.primary),
                    SizedBox(width: 8.r),
                    Text(
                      'search_filters'.tr(),
                      style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _type = 0;
                          _duration = 0;
                          _price = SearchProvider.defaultPriceRange;
                          _brands.clear();
                          _rating = 0;
                        });
                      },
                      child: Text(
                        'search_reset'.tr(),
                        style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: const Color(0xFFE91E63)),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('search_filter_type'.tr(), cs),
                      SizedBox(height: 10.r),
                      _chipWrap(
                        items: _typeLabels,
                        icons: _typeIcons,
                        activeIndex: _type,
                        onTap: (i) => setState(() => _type = i),
                        isDark: isDark,
                        cs: cs,
                      ),
                      SizedBox(height: 20.r),
                      _sectionTitle('search_filter_duration'.tr(), cs),
                      SizedBox(height: 10.r),
                      _chipWrap(
                        items: _durationLabels,
                        icons: _durationIcons,
                        activeIndex: _duration,
                        onTap: (i) => setState(() => _duration = i),
                        isDark: isDark,
                        cs: cs,
                      ),
                      SizedBox(height: 20.r),
                      _sectionTitle('search_filter_price'.tr(), cs),
                      SizedBox(height: 6.r),
                      Row(
                        children: [
                          OmrIcon(size: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                          SizedBox(width: 3.r),
                          Text(
                            '${_price.start.toInt()}',
                            style: TextStyle(
                              fontSize: 12.r,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          OmrIcon(size: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                          SizedBox(width: 3.r),
                          Text(
                            '${_price.end.toInt()}',
                            style: TextStyle(
                              fontSize: 12.r,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: cs.primary,
                          inactiveTrackColor: cs.onSurface.withValues(alpha: 0.1),
                          thumbColor: cs.primary,
                          overlayColor: cs.primary.withValues(alpha: 0.1),
                          trackHeight: 3.r,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
                        ),
                        child: RangeSlider(
                          values: _price,
                          min: 0,
                          max: 500,
                          divisions: 50,
                          onChanged: (v) => setState(() => _price = v),
                        ),
                      ),
                      SizedBox(height: 12.r),
                      if (_type != 2) ...[
                        _sectionTitle('search_filter_brands'.tr(), cs),
                        SizedBox(height: 10.r),
                        Wrap(
                          spacing: 8.r,
                          runSpacing: 8.r,
                          children: kSearchBrands.map((b) {
                            final active = _brands.contains(b);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (active) {
                                  _brands.remove(b);
                                } else {
                                  _brands.add(b);
                                }
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
                                decoration: BoxDecoration(
                                  gradient: active
                                      ? const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF3D5AFE)])
                                      : null,
                                  color: active
                                      ? null
                                      : (isDark
                                            ? Colors.white.withValues(alpha: 0.06)
                                            : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: active
                                        ? Colors.transparent
                                        : (isDark
                                              ? Colors.white.withValues(alpha: 0.08)
                                              : Colors.black.withValues(alpha: 0.06)),
                                  ),
                                ),
                                child: Text(
                                  b,
                                  style: TextStyle(
                                    fontSize: 12.r,
                                    fontWeight: FontWeight.w600,
                                    color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.r),
                      ],
                      _sectionTitle('search_filter_rating'.tr(), cs),
                      SizedBox(height: 10.r),
                      Row(
                        children: List.generate(5, (i) {
                          final starVal = (i + 1).toDouble();
                          final active = _rating >= starVal;
                          return GestureDetector(
                            onTap: () => setState(() => _rating = _rating == starVal ? 0 : starVal),
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(end: 8.r),
                              child: Icon(
                                active ? Iconsax.star_1_copy : Iconsax.star_1,
                                size: 28.r,
                                color: active ? const Color(0xFFFFC107) : cs.onSurface.withValues(alpha: 0.2),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 4.r),
                      if (_rating > 0)
                        Text(
                          '${'search_filter_min_rating'.tr()} ${_rating.toInt()}+',
                          style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.45)),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 16.r),
                child: GestureDetector(
                  onTap: () => widget.onApply(_type, _duration, _price, _brands, _rating),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF3D5AFE)]),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C2485).withValues(alpha: 0.3),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.r),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'search_apply_filters'.tr(),
                        style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, ColorScheme cs) {
    return Text(
      text,
      style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.7)),
    );
  }

  Widget _chipWrap({
    required List<String> items,
    required List<IconData> icons,
    required int activeIndex,
    required ValueChanged<int> onTap,
    required bool isDark,
    required ColorScheme cs,
  }) {
    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: List.generate(items.length, (i) {
        final active = activeIndex == i;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 9.r),
            decoration: BoxDecoration(
              gradient: active ? const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF3D5AFE)]) : null,
              color: active
                  ? null
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: active
                    ? Colors.transparent
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icons[i], size: 14.r, color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.5)),
                SizedBox(width: 6.r),
                Text(
                  items[i].tr(),
                  style: TextStyle(
                    fontSize: 12.r,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
