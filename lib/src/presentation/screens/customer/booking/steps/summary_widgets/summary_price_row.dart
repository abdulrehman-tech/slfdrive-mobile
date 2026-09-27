import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../widgets/omr_icon.dart';

class SummaryPriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? highlight;
  const SummaryPriceRow({
    super.key,
    required this.label,
    required this.amount,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          OmrAmount(
            amount.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 12.r,
              fontWeight: FontWeight.w700,
              color: highlight ?? cs.onSurface,
            ),
            iconColor: highlight ?? cs.onSurface.withValues(alpha: 0.7),
            gap: 2.r,
          ),
        ],
      ),
    );
  }
}
