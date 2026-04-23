import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/driver_earnings_provider.dart';

class EarningsPeriodSelector extends StatelessWidget {
  final bool isDark;

  const EarningsPeriodSelector({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
            DriverEarningsProvider.periodKeys.length,
            (i) => _PeriodTab(
              label: DriverEarningsProvider.periodKeys[i].tr(),
              index: i,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final int index;
  final bool isDark;

  const _PeriodTab({
    required this.label,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverEarningsProvider>();
    final isSelected = provider.periodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<DriverEarningsProvider>().setPeriodIndex(index),
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.r,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isDark
                  ? (isSelected ? Colors.white : Colors.white60)
                  : (isSelected ? Colors.black87 : const Color(0xFF757575)),
            ),
          ),
        ),
      ),
    );
  }
}
