import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/favorites_filter.dart';
import '../provider/favorites_provider.dart';

class FavoritesFilterChips extends StatelessWidget {
  final bool isDark;

  const FavoritesFilterChips({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<FavoritesProvider>();

    return Row(
      children: kFavoritesFilters.asMap().entries.map((entry) {
        final i = entry.key;
        final filter = entry.value;
        final active = provider.filterIndex == i;

        return Padding(
          padding: EdgeInsetsDirectional.only(end: 10.r),
          child: GestureDetector(
            onTap: () => context.read<FavoritesProvider>().setFilter(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
              decoration: BoxDecoration(
                color: active
                    ? filter.color.withValues(alpha: isDark ? 0.2 : 0.12)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04)),
                borderRadius: BorderRadius.circular(14.r),
                border: active
                    ? Border.all(color: filter.color.withValues(alpha: 0.3))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 15.r,
                    color: active
                        ? filter.color
                        : cs.onSurface.withValues(alpha: 0.5),
                  ),
                  SizedBox(width: 6.r),
                  Text(
                    filter.labelKey.tr(),
                    style: TextStyle(
                      fontSize: 12.r,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? filter.color
                          : cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
