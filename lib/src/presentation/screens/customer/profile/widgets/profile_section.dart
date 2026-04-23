import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;
  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.r, 0, 4.r, 10.r),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.r,
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.4,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.055) : Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }
}
