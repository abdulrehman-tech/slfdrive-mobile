import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared glassmorphism card used throughout the booking flow.
class BookingGlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;

  const BookingGlassCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding,
    this.borderRadius = 18,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(borderRadius.r),
            border: Border.all(
              color: borderColor ??
                  (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 16.r,
                offset: Offset(0, 4.r),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

/// Section header used inside booking steps (icon + title + optional trailing).
class BookingSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final bool isDark;

  const BookingSectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, size: 15.r, color: iconColor),
        ),
        SizedBox(width: 10.r),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
