import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/phone_login_provider.dart';

class PhoneLoginDeliveryChip extends StatelessWidget {
  final String method;
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isWhatsApp;

  const PhoneLoginDeliveryChip({
    super.key,
    required this.method,
    required this.label,
    required this.icon,
    required this.isDark,
    this.isWhatsApp = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhoneLoginProvider>();
    final isSelected = provider.selectedDeliveryMethod == method;

    return GestureDetector(
      onTap: () => context.read<PhoneLoginProvider>().selectDeliveryMethod(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 12.r),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isWhatsApp
                ? FaIcon(
                    icon,
                    size: 20.r,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF757575)),
                  )
                : Icon(
                    icon,
                    size: 20.r,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF757575)),
                  ),
            SizedBox(width: 8.r),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.r,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF3D3D3D)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
