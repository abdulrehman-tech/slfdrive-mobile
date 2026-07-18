import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One column of [RevenueBarChart]: a short axis [label] (e.g. a weekday or
/// month), its [value] (revenue in OMR), and whether it should be [highlighted]
/// (e.g. "today" / the current period).
class RevenueBar {
  final String label;
  final double value;
  final bool highlighted;

  const RevenueBar({
    required this.label,
    required this.value,
    this.highlighted = false,
  });
}

/// A dependency-free bar chart for driver revenue. Heights are normalised
/// against the largest [RevenueBar.value] in the set; an all-zero set renders
/// faint flat bars (no divide-by-zero). Colours are injected so the same widget
/// serves both the blue home earnings card and the white earnings screen.
class RevenueBarChart extends StatelessWidget {
  final List<RevenueBar> bars;

  /// Fill for a highlighted bar / the tallest emphasis colour.
  final Color barColor;

  /// Fill for the ordinary (non-highlighted) bars.
  final Color trackColor;

  final Color labelColor;
  final Color highlightLabelColor;

  /// Max pixel height a full-value bar occupies (already `.r`-scaled by caller
  /// intent — pass a `.r` value).
  final double maxBarHeight;

  const RevenueBarChart({
    super.key,
    required this.bars,
    required this.barColor,
    required this.trackColor,
    required this.labelColor,
    required this.highlightLabelColor,
    required this.maxBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<double>(
      0,
      (m, b) => b.value > m ? b.value : m,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < bars.length; i++) ...[
          if (i > 0) SizedBox(width: 6.r),
          Expanded(child: _Bar(
            bar: bars[i],
            maxValue: maxValue,
            barColor: barColor,
            trackColor: trackColor,
            labelColor: labelColor,
            highlightLabelColor: highlightLabelColor,
            maxBarHeight: maxBarHeight,
          )),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final RevenueBar bar;
  final double maxValue;
  final Color barColor;
  final Color trackColor;
  final Color labelColor;
  final Color highlightLabelColor;
  final double maxBarHeight;

  const _Bar({
    required this.bar,
    required this.maxValue,
    required this.barColor,
    required this.trackColor,
    required this.labelColor,
    required this.highlightLabelColor,
    required this.maxBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Fraction of the tallest bar; a tiny floor keeps empty days visible.
    final fraction = maxValue <= 0 ? 0.06 : (bar.value / maxValue).clamp(0.06, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          height: maxBarHeight * fraction,
          decoration: BoxDecoration(
            color: bar.highlighted ? barColor : trackColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
          ),
        ),
        SizedBox(height: 8.r),
        Text(
          bar.label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: 10.r,
            fontWeight: bar.highlighted ? FontWeight.w600 : FontWeight.normal,
            color: bar.highlighted ? highlightLabelColor : labelColor,
          ),
        ),
      ],
    );
  }
}
