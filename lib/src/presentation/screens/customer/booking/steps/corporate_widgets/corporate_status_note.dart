import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../profile/corporate/models/membership_status.dart';

/// Inline note shown beneath the corporate toggle when the user can't
/// currently book as corporate. Includes an action CTA when applicable.
class CorporateStatusNote extends StatelessWidget {
  final MembershipStatus status;
  final bool isDark;
  const CorporateStatusNote({super.key, required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final messageKey = switch (status) {
      MembershipStatus.notApplied => 'booking_corporate_unapproved_note',
      MembershipStatus.pending => 'booking_corporate_pending_note',
      MembershipStatus.rejected => 'booking_corporate_rejected_note',
      MembershipStatus.approved => '',
    };
    final showCta = status == MembershipStatus.notApplied || status == MembershipStatus.rejected;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(status.icon, size: 18.r, color: color),
              SizedBox(width: 10.r),
              Expanded(
                child: Text(
                  messageKey.tr(),
                  style: TextStyle(
                    fontSize: 12.5.r,
                    color: isDark ? Colors.white : const Color(0xFF555555),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          if (showCta) ...[
            SizedBox(height: 10.r),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => context.push('/profile/corporate/apply'),
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                ),
                icon: Icon(Icons.arrow_forward_rounded, size: 16.r),
                label: Text(
                  'booking_corporate_apply_cta'.tr(),
                  style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
