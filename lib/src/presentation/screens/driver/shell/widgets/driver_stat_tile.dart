import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../widgets/omr_icon.dart';

/// Compact stat card (icon, value, label) used in the home quick-stats row and
/// the earnings summary, so both tabs read as one design.
class DriverStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  /// Prefix [value] with the currency symbol.
  final bool isCurrency;

  const DriverStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      fontSize: 20.r,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.r))],
      ),
      child: Column(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(height: 12.r),
          // Scale long values (e.g. a 3-digit average fare) down instead of
          // wrapping or clipping inside a third of the screen width.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: isCurrency ? OmrAmount(value, style: valueStyle) : Text(value, style: valueStyle, maxLines: 1),
          ),
          SizedBox(height: 4.r),
          // Two lines so longer labels ("Avg per Trip", "المتوسط لكل رحلة")
          // wrap instead of truncating; the row's tiles stretch to match.
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
          ),
        ],
      ),
    );
  }
}
