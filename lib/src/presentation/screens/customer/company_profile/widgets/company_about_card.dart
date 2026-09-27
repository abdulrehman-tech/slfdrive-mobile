import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/company/company_profile.dart';
import '../../../../utils/bidi.dart';
import '../../../../utils/contact_launcher.dart';

/// Description plus tappable contact rows (call, email, website, address).
/// Hidden entirely when the company has none of these.
class CompanyAboutCard extends StatefulWidget {
  final CompanyInfo company;
  final bool isDark;

  const CompanyAboutCard({super.key, required this.company, required this.isDark});

  @override
  State<CompanyAboutCard> createState() => _CompanyAboutCardState();
}

class _CompanyAboutCardState extends State<CompanyAboutCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.company;
    final isDark = widget.isDark;
    final rows = <Widget>[
      if (c.contactPhone != null)
        _row(cs, Iconsax.call_copy, ltr(c.contactPhone!), () => ContactLauncher.openPhoneCall(c.contactPhone!)),
      if (c.contactEmail != null)
        _row(cs, Iconsax.sms_copy, c.contactEmail!, () => ContactLauncher.openEmail(c.contactEmail!)),
      if (c.website != null)
        _row(cs, Iconsax.global_copy, c.website!, () {
          final url = c.website!.startsWith('http') ? c.website! : 'https://${c.website!}';
          ContactLauncher.openWebsite(url);
        }),
      if (c.address != null) _row(cs, Iconsax.location_copy, c.address!, null),
    ];
    if (c.description == null && rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.r))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('company_about'.tr(), style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w800, color: cs.onSurface)),
          if (c.description != null) ...[
            SizedBox(height: 8.r),
            // Collapsed to 4 lines so the listings stay near the top; the
            // toggle only appears when the text actually overflows.
            LayoutBuilder(builder: (context, box) {
              final style = TextStyle(fontSize: 13.r, height: 1.5, color: cs.onSurface.withValues(alpha: 0.7));
              final painter = TextPainter(
                text: TextSpan(text: c.description, style: style),
                maxLines: 4,
                textDirection: Directionality.of(context),
              )..layout(maxWidth: box.maxWidth);
              final overflows = painter.didExceedMaxLines;
              painter.dispose();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.description!,
                    maxLines: _expanded ? null : 4,
                    overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: style,
                  ),
                  if (overflows)
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.r),
                        child: Text(
                          (_expanded ? 'company_read_less' : 'company_read_more').tr(),
                          style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.primary),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
          if (rows.isNotEmpty) ...[SizedBox(height: 8.r), ...rows],
        ],
      ),
    );
  }

  Widget _row(ColorScheme cs, IconData icon, String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.r),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
              child: Icon(icon, size: 16.r, color: cs.primary),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: onTap != null ? cs.primary : cs.onSurface),
              ),
            ),
            if (onTap != null) Icon(Icons.chevron_right, size: 18.r, color: cs.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
