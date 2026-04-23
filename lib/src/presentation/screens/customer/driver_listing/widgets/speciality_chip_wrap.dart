import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'speciality_chip.dart';

class SpecialityChipWrap extends StatelessWidget {
  final List<String> specialities;
  final String selected;
  final bool isDark;
  final ColorScheme cs;
  final ValueChanged<String> onSelect;

  const SpecialityChipWrap({
    super.key,
    required this.specialities,
    required this.selected,
    required this.isDark,
    required this.cs,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: specialities
          .map(
            (s) => SpecialityChip(
              label: s,
              active: selected == s,
              isDark: isDark,
              cs: cs,
              onTap: () => onSelect(s),
            ),
          )
          .toList(),
    );
  }
}
