import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class ContinueButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final bool isDesktop;
  final VoidCallback onTap;

  const ContinueButton({
    super.key,
    required this.enabled,
    required this.onTap,
    this.isLoading = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double height = isDesktop ? 60 : 56.r;
    final BorderRadius radius = isDesktop
        ? BorderRadius.circular(16)
        : BorderRadius.circular(16.r);
    final TextStyle textStyle = isDesktop
        ? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)
        : TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600, color: Colors.white);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: enabled ? null : (isDark ? Colors.grey[800] : const Color(0xFFE0E0E0)),
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !isLoading ? onTap : null,
          borderRadius: radius,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: isDesktop ? 24 : 24.r,
                    height: isDesktop ? 24 : 24.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('continue'.tr(), style: textStyle),
          ),
        ),
      ),
    );
  }
}
