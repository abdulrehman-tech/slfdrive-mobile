import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Mobile gradient submit button with disabled state styling.
class SubmitButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const SubmitButton({super.key, required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.r,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: enabled ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
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

  const SubmitButtonDesktop({super.key, required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.r,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: enabled ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
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
