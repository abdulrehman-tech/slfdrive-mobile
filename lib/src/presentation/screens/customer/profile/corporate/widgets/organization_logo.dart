import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/organization.dart';

/// Square org logo with a subtle accent-tinted fallback. Used in the picker,
/// status card, and booking corporate chip.
class OrganizationLogo extends StatelessWidget {
  final Organization organization;
  final double size;
  final bool isDark;

  const OrganizationLogo({
    super.key,
    required this.organization,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: CachedNetworkImage(
        imageUrl: organization.logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => _Fallback(org: organization, size: size, isDark: isDark),
        errorWidget: (_, _, _) => _Fallback(org: organization, size: size, isDark: isDark),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final Organization org;
  final double size;
  final bool isDark;
  const _Fallback({required this.org, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final initials = org.name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: org.accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
          color: org.accentColor,
        ),
      ),
    );
  }
}
