import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/driver_trips_provider.dart';

class DriverTripsTabSelector extends StatelessWidget {
  final bool isDark;

  const DriverTripsTabSelector({super.key, required this.isDark});

  /// Exact height, so the pinned header can reserve precisely this much.
  static double get height => 64.r;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverTripsProvider>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 4.r, 20.r, 12.r),
      child: Container(
        height: 48.r,
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: List.generate(
            DriverTripsProvider.tabKeys.length,
            (i) => _DriverTripsTab(
              label: DriverTripsProvider.tabKeys[i].tr(),
              index: i,
              count: provider.countForTab(i),
              isDark: isDark,
              isSelected: provider.tabIndex == i,
              onTap: () => provider.setTab(i),
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverTripsTab extends StatelessWidget {
  final String label;
  final int index;
  final int count;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _DriverTripsTab({
    required this.label,
    required this.index,
    required this.count,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4.r),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4.r,
                    ),
                  ]
                : null,
          ),
          // Label and count side by side: one row keeps the pinned header
          // short (the stacked badge made it 100pt tall).
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.r,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isDark
                        ? (isSelected ? Colors.white : Colors.white60)
                        : (isSelected ? Colors.black87 : const Color(0xFF757575)),
                  ),
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 6.r),
                Container(
                  constraints: BoxConstraints(minWidth: 20.r),
                  padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4D63DD) : (isDark ? Colors.white24 : Colors.black26),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    count.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
