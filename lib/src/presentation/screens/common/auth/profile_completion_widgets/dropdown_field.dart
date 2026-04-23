import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../widgets/bottom_sheets/dropdown_bottom_sheet.dart';

/// Labeled dropdown field that defers selection UI to [DropdownBottomSheet].
class DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DropdownField({
    super.key,
    required this.value,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.r),
        GestureDetector(
          onTap: () {
            DropdownBottomSheet.show(
              context: context,
              selectedValue: value,
              items: items,
              title: label,
              onSelected: onChanged,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 16.r),
            child: Row(
              children: [
                Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
                SizedBox(width: 12.r),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: FontWeight.w500,
                      color: value == null
                          ? (isDark ? Colors.white38 : const Color(0xFF9E9E9E))
                          : (isDark ? Colors.white : const Color(0xFF3D3D3D)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
