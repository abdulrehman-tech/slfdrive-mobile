import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NotifEmpty extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  const NotifEmpty({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82.r,
            height: 82.r,
            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary.withValues(alpha: 0.08)),
            child: Icon(Iconsax.notification_copy, size: 38.r, color: cs.primary.withValues(alpha: 0.5)),
          ),
          SizedBox(height: 14.r),
          Text(
            'notif_empty_title'.tr(),
            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          SizedBox(height: 4.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.r),
            child: Text(
              'notif_empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
