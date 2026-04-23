import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DriverBottomNav extends StatelessWidget {
  final bool isDark;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const DriverBottomNav({
    super.key,
    required this.isDark,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20.r, offset: Offset(0, -4.r))],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 12.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Iconsax.home_2, label: 'driver_home'.tr(), index: 0, selectedIndex: selectedIndex, onSelect: onSelect),
              _NavItem(icon: Iconsax.wallet_3, label: 'driver_earnings'.tr(), index: 1, selectedIndex: selectedIndex, onSelect: onSelect),
              _NavItem(icon: Iconsax.car, label: 'driver_trips'.tr(), index: 2, selectedIndex: selectedIndex, onSelect: onSelect),
              _NavItem(icon: Iconsax.user, label: 'driver_profile'.tr(), index: 3, selectedIndex: selectedIndex, onSelect: onSelect),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => onSelect(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24.r, color: isActive ? const Color(0xFF4D63DD) : Colors.grey),
          SizedBox(height: 4.r),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.r,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? const Color(0xFF4D63DD) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
