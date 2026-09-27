import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/company/company_profile.dart';
import '../../../../utils/bidi.dart';
import '../../../../widgets/network_logo.dart';

/// Collapsing brand-gradient header: large logo, name and headline stats when
/// expanded; the company name in the toolbar once collapsed.
class CompanyHeader extends StatelessWidget {
  final CompanyProfile profile;
  final bool ar;

  const CompanyHeader({super.key, required this.profile, required this.ar});

  static const _navy = Color(0xFF0C2485);

  @override
  Widget build(BuildContext context) {
    final c = profile.company;
    final name = c.displayName(ar: ar);
    final topPad = MediaQuery.paddingOf(context).top;
    final expanded = 250.r;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expanded,
      backgroundColor: _navy,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 8.r),
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(isRtl(context) ? Iconsax.arrow_right_3_copy : Iconsax.arrow_left_2_copy, color: Colors.white),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, box) {
          // 0 = fully expanded, 1 = collapsed to the toolbar.
          final t = ((expanded + topPad - box.maxHeight) / (expanded - kToolbarHeight)).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0C2485), Color(0xFF3D5AFE)],
                  ),
                ),
              ),
              Opacity(
                opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.r, topPad + kToolbarHeight - 8.r, 20.r, 18.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // White ring around the logo; the image fills the circle
                      // (company "logos" are often photos, which look lost
                      // when inset and contained).
                      Container(
                        width: 84.r,
                        height: 84.r,
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16.r)],
                        ),
                        child: ClipOval(
                          child: ColoredBox(
                            color: Colors.white,
                            child: NetworkLogo(
                              url: c.resolvedLogoUrl,
                              name: name,
                              fit: BoxFit.cover,
                              letterStyle: TextStyle(fontSize: 32.r, fontWeight: FontWeight.w900, color: _navy),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.r),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      SizedBox(height: 10.r),
                      _StatsRow(profile: profile),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 64.r,
                right: 64.r,
                top: topPad,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: ((t - 0.6) / 0.4).clamp(0.0, 1.0),
                  child: Center(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Rating · vehicles · completed trips, as translucent pills.
class _StatsRow extends StatelessWidget {
  final CompanyProfile profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final s = profile.stats;
    final pills = <(IconData, String)>[
      if (s.averageRating != null)
        (Iconsax.star_1, '${s.averageRating!.toStringAsFixed(1)} (${s.totalReviews})')
      else
        (Iconsax.star_1, 'company_new'.tr()),
      (Iconsax.car, 'company_vehicles_count'.plural(profile.vehicles.length)),
      if (s.completedBookings > 0) (Iconsax.tick_circle, 'units_trips'.plural(s.completedBookings)),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.r,
      runSpacing: 6.r,
      children: [
        for (final (icon, label) in pills)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13.r, color: icon == Iconsax.star_1 ? const Color(0xFFFFC107) : Colors.white),
                SizedBox(width: 5.r),
                Text(ltr(label), style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
      ],
    );
  }
}
