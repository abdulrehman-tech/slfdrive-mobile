import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/color_constants.dart';
import '../../../../utils/contact_launcher.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/driver_profile.dart';

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
    return ClipRRect(
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
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'driver_detail_from'.tr(),
                    style: TextStyle(
                      fontSize: 10.r,
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OmrIcon(size: 15.r, color: cs.primary),
                      SizedBox(width: 3.r),
                      Text(
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
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ContactLauncher.openWhatsApp(
                  profile.phone,
                  message: 'Hi ${profile.name}, I would like to hire you through SLF Drive.',
                ),
                child: Container(
                  width: 48.r,
                  height: 48.r,
                  margin: EdgeInsetsDirectional.only(end: 8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.35)),
                  ),
                  child: Icon(Iconsax.message_copy, color: const Color(0xFF25D366), size: 19.r),
                ),
              ),
              GestureDetector(
                onTap: () => ContactLauncher.openPhoneCall(profile.phone),
                child: Container(
                  width: 48.r,
                  height: 48.r,
                  margin: EdgeInsetsDirectional.only(end: 8.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  child: Icon(Iconsax.call_copy, color: cs.primary, size: 19.r),
                ),
              ),
              GestureDetector(
                onTap: onHire,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22.r, vertical: 14.r),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                        blurRadius: 14.r,
                        offset: Offset(0, 5.r),
                      ),
                    ],
                  ),
                  child: Text(
                    'driver_detail_hire'.tr(),
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
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
