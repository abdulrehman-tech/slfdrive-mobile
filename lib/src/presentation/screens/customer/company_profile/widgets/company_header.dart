import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/company/company_profile.dart';
import '../../../../utils/bidi.dart';
import '../../../../widgets/network_logo.dart';

/// Collapsing brand-gradient hero: logo plate beside the name and company type
/// when expanded; a compact logo + name in the toolbar once collapsed.
///
/// The expanded content is a single fixed-height row (logo height), so long
/// names wrap to two lines inside it instead of overflowing the header.
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
    final logo = 76.r;
    // Toolbar + logo row + bottom margin.
    final expanded = kToolbarHeight + logo + 28.r;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expanded,
      backgroundColor: _navy,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      leadingWidth: 64.r,
      leading: Center(
        child: _GlassButton(
          icon: isRtl(context) ? Iconsax.arrow_right_3_copy : Iconsax.arrow_left_2_copy,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, box) {
          // 0 = fully expanded, 1 = collapsed to the toolbar.
          final t = ((expanded + topPad - box.maxHeight) / (expanded - kToolbarHeight)).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              const _HeroBackground(),
              // Expanded: logo + name row pinned to the bottom edge, fading
              // and sliding up slightly as the header collapses.
              Positioned(
                left: 20.r,
                right: 20.r,
                bottom: 20.r,
                height: logo,
                child: Opacity(
                  opacity: (1 - t * 1.8).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -12.r * t),
                    child: Row(
                      children: [
                        CompanyAvatar(
                          companyId: c.id,
                          name: name,
                          size: logo,
                          radius: 20.r,
                          shadow: true,
                          logoUrl: c.resolvedLogoUrl,
                        ),
                        SizedBox(width: 14.r),
                        Expanded(child: _NameBlock(name: name, profile: profile)),
                      ],
                    ),
                  ),
                ),
              ),
              // Collapsed: compact logo + name centred in the toolbar.
              Positioned(
                left: 64.r,
                right: 64.r,
                top: topPad,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: ((t - 0.55) / 0.45).clamp(0.0, 1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CompanyAvatar(companyId: c.id, name: name, size: 28.r, radius: 8.r, logoUrl: c.resolvedLogoUrl),
                      SizedBox(width: 8.r),
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
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

/// Name (up to two lines) over a "Rental company · ★ 4.8" meta line. Text
/// scaling is capped here because the block lives in a fixed-height row.
class _NameBlock extends StatelessWidget {
  final String name;
  final CompanyProfile profile;
  const _NameBlock({required this.name, required this.profile});

  @override
  Widget build(BuildContext context) {
    final rating = profile.stats.averageRating;
    final meta = TextStyle(fontSize: 12.r, height: 1.3, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8));
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
          ),
          SizedBox(height: 6.r),
          Row(
            children: [
              Icon(Iconsax.verify, size: 14.r, color: const Color(0xFF8FD3FF)),
              SizedBox(width: 4.r),
              Flexible(
                child: Text('company_type_rental'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: meta),
              ),
              if (rating != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.r),
                  child: Text('·', style: meta),
                ),
                Icon(Icons.star_rounded, size: 14.r, color: const Color(0xFFFFC107)),
                SizedBox(width: 2.r),
                Text(ltr(rating.toStringAsFixed(1)), style: meta.copyWith(color: Colors.white)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Navy→indigo gradient with two soft rings for depth.
class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    Widget ring(double size, double alpha) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: alpha), width: size * 0.12),
          ),
        );
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0C2485), Color(0xFF2640C9), Color(0xFF4F63F7)],
            ),
          ),
        ),
        PositionedDirectional(top: -60.r, end: -50.r, child: ring(200.r, 0.06)),
        PositionedDirectional(bottom: -70.r, end: 70.r, child: ring(140.r, 0.04)),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 40.r, height: 40.r, child: Icon(icon, size: 20.r, color: Colors.white)),
      ),
    );
  }
}
