import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/search_provider.dart';

class SearchAppBar extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onFilterTap;

  const SearchAppBar({
    super.key,
    required this.isDark,
    required this.cs,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 12.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0E0E1C).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.88),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(CupertinoIcons.back, size: 18.r, color: cs.onSurface),
                ),
              ),
              SizedBox(width: 10.r),
              Expanded(
                child: Container(
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 12.r),
                      Icon(Iconsax.search_normal_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      SizedBox(width: 8.r),
                      Expanded(
                        child: TextField(
                          controller: provider.searchController,
                          focusNode: provider.focusNode,
                          onChanged: provider.setQuery,
                          decoration: InputDecoration(
                            hintText: 'search_hint'.tr(),
                            hintStyle: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.35)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12.r),
                            isCollapsed: true,
                          ),
                          style: TextStyle(fontSize: 14.r, color: cs.onSurface),
                        ),
                      ),
                      if (provider.query.isNotEmpty)
                        GestureDetector(
                          onTap: provider.clearQuery,
                          child: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Icon(Iconsax.close_circle, size: 18.r, color: cs.onSurface.withValues(alpha: 0.4)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.r),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    gradient: provider.hasActiveFilters
                        ? const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF677EF0)])
                        : null,
                    color: provider.hasActiveFilters
                        ? null
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Iconsax.setting_4,
                        size: 20.r,
                        color: provider.hasActiveFilters ? Colors.white : cs.onSurface.withValues(alpha: 0.6),
                      ),
                      if (provider.activeFilterCount > 0)
                        Positioned(
                          top: 6.r,
                          right: 6.r,
                          child: Container(
                            width: 14.r,
                            height: 14.r,
                            decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '${provider.activeFilterCount}',
                                style: TextStyle(fontSize: 8.r, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
