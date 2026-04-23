import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/home_provider.dart';
import 'section_header.dart';

class BrandsSection extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  const BrandsSection({super.key, this.isDesktop = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final home = context.watch<HomeProvider>();
    final brands = home.brands;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'home_all_brands'.tr(),
          cs: cs,
          onViewAll: () => context.pushNamed('brands'),
          isDesktop: isDesktop,
        ),
        SizedBox(
          height: 98.r,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16.r),
            itemCount: brands.length,
            itemBuilder: (_, i) {
              final brand = brands[i];
              final selected = home.selectedBrandIndex == i;
              return GestureDetector(
                onTap: () {
                  home.toggleBrand(i);
                  context.pushNamed('car-listing', extra: {'brand': brand.name});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: EdgeInsetsDirectional.only(end: 14.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 58.r,
                        height: 58.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? (selected ? cs.primary.withValues(alpha: 0.15) : const Color(0xFF1E1E2E))
                              : (selected ? cs.primary.withValues(alpha: 0.08) : Colors.white),
                          border: Border.all(
                            color: selected
                                ? cs.primary
                                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
                            width: selected ? 2.5 : 1.5,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.25),
                                    blurRadius: 12.r,
                                    offset: Offset(0, 4.r),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                    blurRadius: 8.r,
                                    offset: Offset(0, 2.r),
                                  ),
                                ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Image.asset(
                              brand.logoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  brand.name[0],
                                  style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.primary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.r),
                      Text(
                        brand.name,
                        style: TextStyle(
                          fontSize: 10.r,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
