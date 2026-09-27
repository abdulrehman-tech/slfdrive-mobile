import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../widgets/omr_icon.dart';

class EarningsStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  /// Prefix [value] with the currency symbol.
  final bool isCurrency;

  const EarningsStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.isCurrency = false,
  });

  TextStyle get _valueStyle => TextStyle(
        fontSize: 18.r,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black87,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.r),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.r,
                    color: isDark ? Colors.white60 : const Color(0xFF757575),
                  ),
                ),
                SizedBox(height: 4.r),
                if (isCurrency) OmrAmount(value, style: _valueStyle) else Text(value, style: _valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
