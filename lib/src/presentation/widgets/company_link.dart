import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'network_logo.dart';

/// Opens a rental company's profile page.
void openCompanyProfile(BuildContext context, int companyId) =>
    context.pushNamed('company-profile', pathParameters: {'id': '$companyId'});

/// "[logo] Company name ›" — the owning rental company as a tappable link to
/// its profile. Renders as plain text when [companyId] is null (no profile to open).
class CompanyLink extends StatelessWidget {
  final String name;
  final int? companyId;
  final double fontSize;
  final Color? color;

  const CompanyLink({super.key, required this.name, required this.companyId, this.fontSize = 11, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.primary;
    final tappable = companyId != null;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CompanyAvatar(companyId: companyId, name: name, size: (fontSize + 6).r, radius: 4.r),
        SizedBox(width: 5.r),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize.r, fontWeight: FontWeight.w600, color: c),
          ),
        ),
        if (tappable) Icon(Icons.chevron_right, size: (fontSize + 3).r, color: c.withValues(alpha: 0.7)),
      ],
    );
    if (!tappable) return row;
    // Opaque hit area with a little vertical slop so the small line is easy
    // to hit without triggering the parent card's own tap.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openCompanyProfile(context, companyId!),
      child: Padding(padding: EdgeInsets.symmetric(vertical: 3.r), child: row),
    );
  }
}
