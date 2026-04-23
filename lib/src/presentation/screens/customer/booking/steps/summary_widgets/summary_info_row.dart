import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool multi;
  const SummaryInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.multi = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.r),
      child: Row(
        crossAxisAlignment: multi ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110.r,
            child: Text(
              label,
              style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
