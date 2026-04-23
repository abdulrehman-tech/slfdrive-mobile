import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnreadBadge extends StatelessWidget {
  final int count;
  final ColorScheme cs;
  const UnreadBadge({super.key, required this.count, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(10.r)),
      child: Text(
        '$count',
        style: TextStyle(fontSize: 11.r, color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
  }
}
