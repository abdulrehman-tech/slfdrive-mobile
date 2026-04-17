import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact Omani plate badge.
///
/// Minimal pill showing a tiny red "OM" tag + digits + letter code.
/// Sized conservatively so it doesn't dominate any card it's placed in.
class OmanPlate extends StatelessWidget {
  final String number;
  final String code;
  // `width` kept for API compatibility but the widget now self-sizes.
  // ignore: unused_element_parameter
  final double width;
  final bool showLabel;

  const OmanPlate({super.key, required this.number, required this.code, this.width = 0, this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    final plate = Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 5.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: Colors.black87, width: 1.4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6.r, offset: Offset(0, 2.r))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 2.r),
            decoration: BoxDecoration(color: const Color(0xFFDD1F26), borderRadius: BorderRadius.circular(4.r)),
            child: Text(
              'OM',
              style: TextStyle(
                fontSize: 9.r,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 6.r),
          Text(
            number,
            style: TextStyle(
              fontSize: 15.r,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 1.2,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(width: 5.r),
          Container(width: 1, height: 14.r, color: Colors.black26),
          SizedBox(width: 5.r),
          Text(
            code.toUpperCase(),
            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w900, color: Colors.black, height: 1),
          ),
        ],
      ),
    );

    if (!showLabel) return plate;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plate',
          style: TextStyle(
            fontSize: 10.r,
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.5),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 4.r),
        plate,
      ],
    );
  }
}
