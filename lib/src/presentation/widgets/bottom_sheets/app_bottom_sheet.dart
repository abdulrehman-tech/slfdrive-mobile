import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A beautiful glassmorphism bottom sheet wrapper with smooth animations.
/// Use this as the base for all bottom sheets in the app.
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? height;
  final bool showDragHandle;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsets? padding;
  final Widget? headerAction;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.height,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.onClose,
    this.padding,
    this.headerAction,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool showCloseButton = true,
    VoidCallback? onClose,
    EdgeInsets? padding,
    Widget? headerAction,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 300),
      ),
      builder: (context) {
        return AppBottomSheet(
          title: title,
          height: height,
          showDragHandle: showDragHandle,
          showCloseButton: showCloseButton,
          onClose: onClose ?? () => Navigator.pop(context),
          padding: padding,
          headerAction: headerAction,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20.r, offset: Offset(0, -4.r))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                if (showDragHandle) ...[
                  SizedBox(height: 12.r),
                  Container(
                    width: 40.r,
                    height: 4.r,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 8.r),
                ] else
                  SizedBox(height: 16.r),

                // Header
                if (title != null || showCloseButton || headerAction != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.r),
                    child: Row(
                      children: [
                        if (showCloseButton)
                          GestureDetector(
                            onTap: onClose,
                            child: Container(
                              width: 32.r,
                              height: 32.r,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.close, size: 18.r, color: isDark ? Colors.white70 : Colors.black54),
                            ),
                          )
                        else
                          SizedBox(width: 32.r),
                        Expanded(
                          child: title != null
                              ? Text(
                                  title!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18.r,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        if (headerAction != null) headerAction! else SizedBox(width: 32.r),
                      ],
                    ),
                  ),

                if (title != null || showCloseButton || headerAction != null) SizedBox(height: 16.r),

                // Content
                Flexible(
                  child: Padding(
                    padding: padding ?? EdgeInsets.symmetric(horizontal: 20.r),
                    child: child,
                  ),
                ),

                // Safe area for bottom
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16.r),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
