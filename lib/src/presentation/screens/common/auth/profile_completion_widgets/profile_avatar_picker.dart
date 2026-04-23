import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color_constants.dart';

class ProfileAvatarPicker extends StatelessWidget {
  final bool picked;
  final bool isDark;
  final double size;
  final VoidCallback onTap;

  const ProfileAvatarPicker({
    super.key,
    required this.picked,
    required this.isDark,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Outer glow ring
              Container(
                width: size + 8.r,
                height: size + 8.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [secondaryColor.withValues(alpha:0.6), const Color(0xFF0C2485).withValues(alpha:0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.r),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    ),
                    child: picked
                        ? ClipOval(
                            child: Container(
                              color: secondaryColor.withValues(alpha:0.12),
                              child: Icon(Icons.person, size: size * 0.55, color: secondaryColor),
                            ),
                          )
                        : ClipOval(
                            child: Container(
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F2FF),
                              child: Icon(
                                Icons.person_outline,
                                size: size * 0.5,
                                color: isDark ? Colors.white38 : const Color(0xFFB0BAE8),
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // Camera badge
              Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 2.r),
                  boxShadow: [
                    BoxShadow(color: secondaryColor.withValues(alpha:0.35), blurRadius: 8.r, offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(
                  picked ? Icons.edit_outlined : Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: size * 0.16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.r),
        Text(
          picked ? 'photo_added'.tr() : 'tap_to_add_photo'.tr(),
          style: TextStyle(
            fontSize: 12.r,
            color: picked ? secondaryColor : (isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
            fontWeight: picked ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
