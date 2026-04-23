import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/driver_detail_provider.dart';

/// Glass header that fades in on scroll (mobile only).
class GlassHeaderOverlay extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const GlassHeaderOverlay({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverDetailProvider>();
    final profile = provider.profile;
    final topPad = MediaQuery.of(context).padding.top;
    final t = (provider.scrollOffset / 180).clamp(0.0, 1.0);

    return IgnorePointer(
      ignoring: t < 0.35,
      child: Opacity(
        opacity: t,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.fromLTRB(12.r, topPad + 6.r, 12.r, 10.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.74) : Colors.white.withValues(alpha: 0.82),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 16.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w800, color: cs.onSurface),
                    ),
                  ),
                  GestureDetector(
                    onTap: provider.toggleFavourite,
                    child: Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(
                        provider.isFavourite ? Iconsax.heart_copy : Iconsax.heart,
                        size: 16.r,
                        color: provider.isFavourite ? const Color(0xFFE91E63) : cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
