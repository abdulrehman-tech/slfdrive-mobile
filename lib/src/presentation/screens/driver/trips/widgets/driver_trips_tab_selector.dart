import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/driver_trips_provider.dart';

class DriverTripsTabSelector extends StatelessWidget {
  final bool isDark;

  const DriverTripsTabSelector({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverTripsProvider>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 16.r),
      child: Container(
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
          padding: EdgeInsets.symmetric(vertical: 10.r),
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
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.r,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isDark
                      ? (isSelected ? Colors.white : Colors.white60)
                      : (isSelected
                            ? Colors.black87
                            : const Color(0xFF757575)),
                ),
              ),
              if (count > 0) ...[
                SizedBox(height: 4.r),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.r,
                    vertical: 2.r,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4D63DD)
                        : (isDark ? Colors.white24 : Colors.black26),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11.r,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
