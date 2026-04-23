import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/theme_provider.dart';

class ThemeToggleBtn extends StatelessWidget {
  final bool isDark;
  final bool vertical;
  const ThemeToggleBtn({super.key, required this.isDark, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
      child: Container(
        width: vertical ? 44.r : 38.r,
        height: vertical ? 44.r : 38.r,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            isDark ? Iconsax.sun_1 : Iconsax.moon,
            key: ValueKey(isDark),
            color: isDark ? const Color(0xFFFFC107) : cs.onSurface.withValues(alpha: 0.6),
            size: 18.r,
          ),
        ),
      ),
    );
  }
}
