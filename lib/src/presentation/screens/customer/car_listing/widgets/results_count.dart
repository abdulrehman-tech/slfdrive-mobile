import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small muted "N results" label shown above the car list.
class ResultsCount extends StatelessWidget {
  final int count;
  final ColorScheme cs;

  const ResultsCount({super.key, required this.count, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count ${'car_listing_results'.tr()}',
      style: TextStyle(
        fontSize: 12.r,
        color: cs.onSurface.withValues(alpha: 0.5),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
