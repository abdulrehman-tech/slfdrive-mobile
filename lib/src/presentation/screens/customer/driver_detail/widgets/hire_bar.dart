import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../utils/contact_launcher.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/driver_profile.dart';

/// Bottom action bar on a driver's profile. Freelance drivers get "Hire
/// Driver"; company drivers can't be hired on their own, so the primary
/// action becomes "Book a company car" (the caller routes it to the company's
/// vehicles).
class HireBar extends StatelessWidget {
  final DriverProfile profile;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onHire;

  const HireBar({
    super.key,
    required this.profile,
    required this.isDark,
    required this.cs,
    required this.onHire,
  });

  @override
  Widget build(BuildContext context) {
    // Company drivers are only booked with one of their company's cars, so
    // they get no direct WhatsApp / call — just "Book a car".
    final company = profile.companyId != null;
    // Fixed-height chrome: cap text scaling like the other bottom bars.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 12.r + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, box) => Row(
                children: [
                  // Price gives way first: it scales down rather than
                  // squeezing the action label.
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: _price(),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  if (!company) ...[
                    _iconAction(
                      icon: Iconsax.message_copy,
                      color: const Color(0xFF25D366),
                      onTap: () => ContactLauncher.openWhatsApp(
                        profile.phone,
                        message: 'Hi ${profile.name}, I would like to hire you through SLF Drive.',
                      ),
                    ),
                    _iconAction(
                      icon: Iconsax.call_copy,
                      color: cs.primary,
                      onTap: () => ContactLauncher.openPhoneCall(profile.phone),
                    ),
                  ],
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: box.maxWidth * (company ? 0.6 : 0.42)),
                    child: _primaryButton(company),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _price() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'driver_detail_from'.tr(),
          style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.45), fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 2.r),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            OmrAmount(
              '${profile.dailyRate.toInt()}',
              style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.w900, color: cs.primary),
            ),
            Text(
              '/${'day'.tr()}',
              style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.r,
        height: 48.r,
        margin: EdgeInsetsDirectional.only(end: 8.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.12),
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: color, size: 19.r),
      ),
    );
  }

  /// "Hire Driver" (freelance) or "Book a car" (company driver). The label
  /// scales down to fit its share of the bar instead of being cut off.
  Widget _primaryButton(bool company) {
    return GestureDetector(
      onTap: onHire,
      child: Container(
        height: 48.r,
        padding: EdgeInsets.symmetric(horizontal: 20.r),
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0C2485).withValues(alpha: 0.35), blurRadius: 14.r, offset: Offset(0, 5.r)),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (company) ...[
                Icon(Iconsax.car_copy, size: 17.r, color: Colors.white),
                SizedBox(width: 6.r),
              ],
              Text(
                (company ? 'driver_detail_book_company' : 'driver_detail_hire').tr(),
                maxLines: 1,
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
