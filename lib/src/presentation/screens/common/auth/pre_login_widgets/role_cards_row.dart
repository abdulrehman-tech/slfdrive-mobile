import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'role_card.dart';

/// Two-column passenger/driver role picker. Both cards push into
/// `/auth/phone` with an `isDriver` flag so the downstream flow branches
/// correctly.
class RoleCardsRow extends StatelessWidget {
  final bool isDesktop;

  const RoleCardsRow({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final gap = isDesktop ? 20.r : 12.r;
    final passenger = isDesktop
        ? RoleCard.desktop(
            icon: Icons.person_outline_rounded,
            title: 'pre_login_passenger'.tr(),
            subtitle: 'pre_login_passenger_desc'.tr(),
            onTap: () => context.push('/auth/phone', extra: {'isDriver': false}),
          )
        : RoleCard.mobile(
            icon: Icons.person_outline_rounded,
            title: 'pre_login_passenger'.tr(),
            subtitle: 'pre_login_passenger_desc'.tr(),
            onTap: () => context.push('/auth/phone', extra: {'isDriver': false}),
          );
    final driver = isDesktop
        ? RoleCard.desktop(
            icon: Icons.drive_eta_rounded,
            title: 'become_driver'.tr(),
            subtitle: 'pre_login_driver_desc'.tr(),
            onTap: () => context.push('/auth/phone', extra: {'isDriver': true}),
          )
        : RoleCard.mobile(
            icon: Icons.drive_eta_rounded,
            title: 'become_driver'.tr(),
            subtitle: 'pre_login_driver_desc'.tr(),
            onTap: () => context.push('/auth/phone', extra: {'isDriver': true}),
          );

    return Row(
      children: [
        Expanded(child: passenger),
        SizedBox(width: gap),
        Expanded(child: driver),
      ],
    );
  }
}
