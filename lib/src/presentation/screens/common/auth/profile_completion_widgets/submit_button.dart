import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Mobile gradient submit button with disabled state styling.
class SubmitButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool loading;

  const SubmitButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return Container(
      width: double.infinity,
      height: 56.r,
      decoration: BoxDecoration(
        gradient: active || loading
            ? const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: active || loading ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: active ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 17.r,
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.white : Colors.grey[600],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Desktop variant of [SubmitButton] with slightly larger metrics.
class SubmitButtonDesktop extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool loading;

  const SubmitButtonDesktop({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return Container(
      width: double.infinity,
      height: 60.r,
      decoration: BoxDecoration(
        gradient: active || loading
            ? const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: active || loading ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: active ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 18.r,
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.white : Colors.grey[600],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
