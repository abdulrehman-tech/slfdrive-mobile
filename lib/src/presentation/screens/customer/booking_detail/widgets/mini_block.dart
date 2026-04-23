import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingMiniBlock extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;
  final String label;
  final String value;

  const BookingMiniBlock({
    super.key,
    required this.cs,
    required this.isDark,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5))),
          SizedBox(height: 4.r),
          Text(value, style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }
}
