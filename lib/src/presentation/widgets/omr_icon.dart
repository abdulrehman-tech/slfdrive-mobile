import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable Omani Rial (OMR) currency icon widget.
/// Uses `omr_black.svg` for light mode and `omr_white.svg` for dark mode.
/// Optionally accepts a custom [color] to override the default behavior.
class OmrIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const OmrIcon({super.key, this.size = 14, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color;

    if (effectiveColor != null) {
      return SvgPicture.asset(
        'assets/icons/omr_black.svg',
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
      );
    }

    return SvgPicture.asset(
      isDark ? 'assets/icons/omr_white.svg' : 'assets/icons/omr_black.svg',
      width: size,
      height: size,
    );
  }
}
