import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color_constants.dart';

/// Mobile document upload tile showing empty/filled states.
class DocumentPickerTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final String? fileName;
  final bool isDark;
  final VoidCallback onTap;

  const DocumentPickerTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.fileName,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasFile ? secondaryColor.withValues(alpha: 0.5) : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: hasFile ? secondaryColor.withValues(alpha: 0.12) : (isDark ? Colors.white12 : Colors.white),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                hasFile ? Icons.check_circle_outline : icon,
                color: hasFile ? secondaryColor : (isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    hasFile ? fileName! : subtitle,
                    style: TextStyle(
                      fontSize: 12.r,
                      color: hasFile ? secondaryColor : (isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.edit_outlined : Icons.upload_file_outlined,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop variant of [DocumentPickerTile] with bigger padding and typography.
class DocumentPickerTileDesktop extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final String? fileName;
  final bool isDark;
  final VoidCallback onTap;

  const DocumentPickerTileDesktop({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.fileName,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasFile ? secondaryColor.withValues(alpha: 0.5) : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: hasFile ? secondaryColor.withValues(alpha: 0.12) : (isDark ? Colors.white12 : Colors.white),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                hasFile ? Icons.check_circle_outline : icon,
                color: hasFile ? secondaryColor : (isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
                size: 24.r,
              ),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),
                  SizedBox(height: 3.r),
                  Text(
                    hasFile ? fileName! : subtitle,
                    style: TextStyle(
                      fontSize: 13.r,
                      color: hasFile ? secondaryColor : (isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.edit_outlined : Icons.upload_file_outlined,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}
