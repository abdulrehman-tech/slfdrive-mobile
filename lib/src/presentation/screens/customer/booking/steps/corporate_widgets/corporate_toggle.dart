import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Two-option segmented control: Personal vs Corporate. Selected option is
/// highlighted with the brand gradient (`#4D63DD → #677EF0`) so it shares the
/// same accent treatment as the rest of the booking flow.
class CorporateToggle extends StatelessWidget {
  final bool isCorporate;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final bool corporateDisabled;

  const CorporateToggle({
    super.key,
    required this.isCorporate,
    required this.onChanged,
    required this.isDark,
    this.corporateDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Option(
            icon: Iconsax.user_copy,
            labelKey: 'booking_corporate_personal',
            subtitleKey: 'booking_corporate_personal_desc',
            isSelected: !isCorporate,
            isDark: isDark,
            onTap: () => onChanged(false),
          ),
        ),
        SizedBox(width: 10.r),
        Expanded(
          child: _Option(
            icon: Iconsax.briefcase_copy,
            labelKey: 'booking_corporate_employee',
            subtitleKey: 'booking_corporate_employee_desc',
            isSelected: isCorporate,
            isDark: isDark,
            disabled: corporateDisabled,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final String subtitleKey;
  final bool isSelected;
  final bool isDark;
  final bool disabled;
  final VoidCallback onTap;

  const _Option({
    required this.icon,
    required this.labelKey,
    required this.subtitleKey,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 14.r),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4D63DD).withValues(alpha: 0.6)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4D63DD).withValues(alpha: 0.3),
                    blurRadius: 14.r,
                    offset: Offset(0, 5.r),
                  ),
                ]
              : null,
        ),
        child: Opacity(
          opacity: disabled ? 0.45 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFF4D63DD).withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  icon,
                  size: 18.r,
                  color: isSelected ? Colors.white : const Color(0xFF4D63DD),
                ),
              ),
              SizedBox(height: 10.r),
              Text(
                labelKey.tr(),
                style: TextStyle(
                  fontSize: 13.r,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : cs.onSurface,
                ),
              ),
              SizedBox(height: 2.r),
              Text(
                subtitleKey.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.r,
                  height: 1.35,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
