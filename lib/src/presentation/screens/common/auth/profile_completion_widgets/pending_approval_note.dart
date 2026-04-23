import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Blue info callout shown to drivers while their profile awaits approval.
class PendingApprovalNote extends StatelessWidget {
  final bool isDark;
  const PendingApprovalNote({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF4D63DD).withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF4D63DD).withValues(alpha:0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFF4D63DD), size: 20.r),
          SizedBox(width: 10.r),
          Expanded(
            child: Text(
              'pending_approval_note'.tr(),
              style: TextStyle(
                fontSize: 13.r,
                color: isDark ? Colors.white70 : const Color(0xFF555555),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
