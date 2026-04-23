import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Frosted-glass role selection card (passenger / driver). Sizing constants
/// are passed in so the same widget serves both mobile and desktop layouts.
class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double borderRadius;
  final double blurSigma;
  final double padding;
  final double iconBoxSize;
  final double iconBoxRadius;
  final double iconSize;
  final double titleSize;
  final double subtitleSize;
  final double gapBeforeTitle;
  final double gapBeforeSubtitle;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.borderRadius,
    required this.blurSigma,
    required this.padding,
    required this.iconBoxSize,
    required this.iconBoxRadius,
    required this.iconSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.gapBeforeTitle,
    required this.gapBeforeSubtitle,
  });

  /// Mobile preset: compact card sized for the 390-wide design baseline.
  factory RoleCard.mobile({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return RoleCard(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      borderRadius: 16.r,
      blurSigma: 12,
      padding: 20.r,
      iconBoxSize: 48.r,
      iconBoxRadius: 12.r,
      iconSize: 26.r,
      titleSize: 15.r,
      subtitleSize: 12.r,
      gapBeforeTitle: 14.r,
      gapBeforeSubtitle: 6.r,
    );
  }

  /// Desktop preset: roomier padding and larger type.
  factory RoleCard.desktop({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return RoleCard(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      borderRadius: 18.r,
      blurSigma: 14,
      padding: 28.r,
      iconBoxSize: 56.r,
      iconBoxRadius: 14.r,
      iconSize: 30.r,
      titleSize: 18.r,
      subtitleSize: 14.r,
      gapBeforeTitle: 16.r,
      gapBeforeSubtitle: 8.r,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(iconBoxRadius),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Icon(icon, color: Colors.white, size: iconSize),
                ),
                SizedBox(height: gapBeforeTitle),
                Text(
                  title,
                  style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: gapBeforeSubtitle),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: subtitleSize, color: Colors.white.withValues(alpha: 0.7), height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
