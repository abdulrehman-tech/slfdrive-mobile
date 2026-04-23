import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color_constants.dart';

/// Compact left-accent section header used by the mobile profile form.
class SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const SectionHeader({super.key, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.r,
          height: 18.r,
          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(width: 8.r),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.r,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Slightly larger section header variant used by the desktop form.
class SectionHeaderDesktop extends StatelessWidget {
  final String label;
  final bool isDark;
  const SectionHeaderDesktop({super.key, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.r,
          height: 20.r,
          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(width: 10.r),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.r,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
