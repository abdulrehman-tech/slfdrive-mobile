import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Mobile-sized labeled text field used throughout the profile form.
class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType keyboardType;

  const InputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
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
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15.r,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 14.r, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
              prefixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 16.r),
            ),
          ),
        ),
      ],
    );
  }
}

/// Desktop-sized variant of [InputField] with slightly bigger typography and padding.
class InputFieldDesktop extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType keyboardType;

  const InputFieldDesktop({
    super.key,
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 10.r),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16.r,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 15.r, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
              prefixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 22.r),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 18.r),
            ),
          ),
        ),
      ],
    );
  }
}
