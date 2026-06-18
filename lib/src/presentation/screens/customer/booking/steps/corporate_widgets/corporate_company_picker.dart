import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../widgets/skeletons/list_skeleton.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../core/models/company/all_company.dart';

/// Opens a bottom sheet listing [companies]; returns the picked one or null.
Future<AllCompany?> showCompanyPickerSheet(
  BuildContext context, {
  required List<AllCompany> companies,
  required bool isDark,
  AllCompany? selected,
  bool isLoading = false,
  String? error,
}) {
  return showModalBottomSheet<AllCompany>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CompanyPickerSheet(
      companies: companies,
      isDark: isDark,
      selected: selected,
      isLoading: isLoading,
      error: error,
    ),
  );
}

class _CompanyPickerSheet extends StatelessWidget {
  final List<AllCompany> companies;
  final bool isDark;
  final AllCompany? selected;
  final bool isLoading;
  final String? error;

  const _CompanyPickerSheet({
    required this.companies,
    required this.isDark,
    required this.selected,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isDark ? const Color(0xFF15151F) : Colors.white;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.r,
              height: 4.r,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.r),
          Text(
            'booking_corporate_select_company'.tr(),
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 14.r),
          if (isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.r),
              child: const ListSkeleton(itemCount: 4, itemHeight: 58, padding: EdgeInsets.zero),
            )
          else if (error != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.r),
              child: Center(
                child: Text(error!, style: TextStyle(color: cs.error, fontSize: 13.r)),
              ),
            )
          else if (companies.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.r),
              child: Center(
                child: Text(
                  'booking_corporate_no_companies'.tr(),
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13.r),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: companies.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.r),
                itemBuilder: (_, i) {
                  final c = companies[i];
                  final isSel = selected?.id == c.id;
                  return _CompanyTile(
                    company: c,
                    isSelected: isSel,
                    isDark: isDark,
                    onTap: () => Navigator.of(context).pop(c),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CompanyTile extends StatelessWidget {
  final AllCompany company;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CompanyTile({
    required this.company,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final logo = company.resolvedLogoUrl;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4D63DD).withValues(alpha: isDark ? 0.18 : 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4D63DD).withValues(alpha: 0.6)
                : (isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: const Color(0xFF4D63DD).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: logo != null
                  ? CachedNetworkImage(
                      imageUrl: logo,
                      fit: BoxFit.cover,
                      errorWidget: (c, u, e) =>
                          Icon(Iconsax.buildings_copy, size: 20.r, color: const Color(0xFF4D63DD)),
                    )
                  : Icon(Iconsax.buildings_copy, size: 20.r, color: const Color(0xFF4D63DD)),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.displayName(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  if ((company.address ?? '').isNotEmpty) ...[
                    SizedBox(height: 2.r),
                    Text(
                      company.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Iconsax.tick_circle_copy, size: 20.r, color: const Color(0xFF4D63DD)),
          ],
        ),
      ),
    );
  }
}
