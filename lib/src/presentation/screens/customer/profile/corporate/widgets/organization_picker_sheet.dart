import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../widgets/bottom_sheets/app_bottom_sheet.dart';
import '../models/organization.dart';
import 'organization_logo.dart';

/// Bottom sheet that lists organizations and resolves with the picked one.
/// Built on top of [AppBottomSheet] so it inherits the app's glassmorphism
/// chrome (drag handle, frosted background, dismiss affordances).
Future<Organization?> showOrganizationPickerSheet(
  BuildContext context, {
  required List<Organization> organizations,
  required bool isDark,
  Organization? selected,
  String? titleKey,
}) {
  return AppBottomSheet.show<Organization>(
    context: context,
    title: (titleKey ?? 'corporate_select_organization').tr(),
    height: MediaQuery.of(context).size.height * 0.7,
    child: _OrganizationList(
      organizations: organizations,
      isDark: isDark,
      selected: selected,
    ),
  );
}

class _OrganizationList extends StatefulWidget {
  final List<Organization> organizations;
  final bool isDark;
  final Organization? selected;

  const _OrganizationList({
    required this.organizations,
    required this.isDark,
    required this.selected,
  });

  @override
  State<_OrganizationList> createState() => _OrganizationListState();
}

class _OrganizationListState extends State<_OrganizationList> {
  late List<Organization> _filtered;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.organizations;
    _search.addListener(_onSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = widget.organizations
          .where((o) =>
              o.name.toLowerCase().contains(q) || o.industry.toLowerCase().contains(q))
          .toList();
    });
  }

  void _select(Organization org) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(org);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    if (widget.organizations.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Text(
            'corporate_no_organization'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.r,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        if (widget.organizations.length > 6) ...[
          Container(
            height: 48.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              controller: _search,
              style: TextStyle(fontSize: 15.r, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                hintStyle: TextStyle(
                  fontSize: 14.r,
                  color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.3),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20.r,
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 14.r),
              ),
            ),
          ),
          SizedBox(height: 12.r),
        ],
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final org = _filtered[i];
              final isSelected = widget.selected?.id == org.id;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: 8.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4D63DD).withValues(alpha: 0.1)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02)),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4D63DD).withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  onTap: () => _select(org),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                  leading: OrganizationLogo(organization: org, size: 44.r, isDark: isDark),
                  title: Text(
                    org.name,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF4D63DD)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  subtitle: Text(
                    org.industry,
                    style: TextStyle(
                      fontSize: 12.r,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  trailing: isSelected
                      ? Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D63DD),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(Icons.check, size: 16.r, color: Colors.white),
                        )
                      : Icon(Iconsax.arrow_right_3_copy, size: 16.r,
                          color: isDark ? Colors.white38 : Colors.black38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
