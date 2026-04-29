import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum MembershipStatus { notApplied, pending, approved, rejected }

extension MembershipStatusX on MembershipStatus {
  Color get color {
    switch (this) {
      case MembershipStatus.notApplied:
        return const Color(0xFF9E9E9E);
      case MembershipStatus.pending:
        return const Color(0xFFFFA726);
      case MembershipStatus.approved:
        return const Color(0xFF4CAF50);
      case MembershipStatus.rejected:
        return const Color(0xFFE53935);
    }
  }

  IconData get icon {
    switch (this) {
      case MembershipStatus.notApplied:
        return Iconsax.add_circle_copy;
      case MembershipStatus.pending:
        return Iconsax.timer_1_copy;
      case MembershipStatus.approved:
        return Iconsax.tick_circle_copy;
      case MembershipStatus.rejected:
        return Iconsax.close_circle_copy;
    }
  }

  String get labelKey {
    switch (this) {
      case MembershipStatus.notApplied:
        return 'corporate_status_not_applied';
      case MembershipStatus.pending:
        return 'corporate_status_pending';
      case MembershipStatus.approved:
        return 'corporate_status_approved';
      case MembershipStatus.rejected:
        return 'corporate_status_rejected';
    }
  }

  String get label => labelKey.tr();
}
