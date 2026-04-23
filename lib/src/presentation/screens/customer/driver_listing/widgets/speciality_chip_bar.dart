import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'speciality_chip.dart';

class SpecialityChipBar extends StatelessWidget {
  final List<String> specialities;
  final String selected;
  final bool isDark;
  final ColorScheme cs;
  final ValueChanged<String> onSelect;

  const SpecialityChipBar({
    super.key,
    required this.specialities,
    required this.selected,
    required this.isDark,
    required this.cs,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.r),
      child: SizedBox(
        height: 44.r,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.r),
          itemCount: specialities.length,
          itemBuilder: (_, i) {
            final label = specialities[i];
            final active = selected == label;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.r),
              child: SpecialityChip(
                label: label,
                active: active,
                isDark: isDark,
                cs: cs,
                onTap: () => onSelect(label),
              ),
            );
          },
        ),
      ),
    );
  }
}
