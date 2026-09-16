import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Back button + search field used at the top of the browse and search
/// screens. The clear button follows the controller's text.
class CatalogSearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;

  const CatalogSearchHeader({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F3F7);
    return Row(
      children: [
        Semantics(
          button: true,
          label: MaterialLocalizations.of(context).backButtonTooltip,
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(12.r)),
              child: Icon(CupertinoIcons.back, size: 18.r, color: cs.onSurface),
            ),
          ),
        ),
        SizedBox(width: 10.r),
        Expanded(
          child: Container(
            height: 44.r,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 12.r),
                Icon(Iconsax.search_normal_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.45)),
                SizedBox(width: 8.r),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      // The app theme fills and outlines inputs; this field
                      // sits inside its own box.
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.r),
                    ),
                    style: TextStyle(fontSize: 14.r, color: cs.onSurface),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, _) => value.text.isEmpty
                      ? SizedBox(width: 8.r)
                      : GestureDetector(
                          onTap: onClear,
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Icon(Iconsax.close_circle, size: 18.r, color: cs.onSurface.withValues(alpha: 0.45)),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
