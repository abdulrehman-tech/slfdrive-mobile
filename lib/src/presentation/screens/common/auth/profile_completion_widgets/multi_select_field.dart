import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../widgets/bottom_sheets/multi_select_bottom_sheet.dart';

/// Labeled multi-select field that joins the selected values for display and
/// opens a [MultiSelectBottomSheet] when tapped.
class MultiSelectField extends StatelessWidget {
  final List<String> values;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  const MultiSelectField({
    super.key,
    required this.values,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  void _openSheet(BuildContext context) {
    MultiSelectBottomSheet.show(
      context: context,
      selectedValues: values,
      items: items,
      title: label,
      onSelectionChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = values.isEmpty ? hint : values.join(', ');

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
          onTap: () => _openSheet(context),
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
                    displayText,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: FontWeight.w500,
                      color: values.isEmpty
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
