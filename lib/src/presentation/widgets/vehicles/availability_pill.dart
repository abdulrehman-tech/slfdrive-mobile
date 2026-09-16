import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Available" / "Unavailable" status pill shown on every car card, so the
/// state is visible either way. [onPhoto] uses solid colours for legibility
/// over images.
class AvailabilityPill extends StatelessWidget {
  final bool available;
  final bool onPhoto;

  const AvailabilityPill({super.key, required this.available, this.onPhoto = false});

  static const _green = Color(0xFF2E7D32);
  static const _red = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    final color = available ? _green : _red;
    final fg = onPhoto ? Colors.white : color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: onPhoto ? color.withValues(alpha: 0.92) : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          SizedBox(width: 4.r),
          Text(
            (available ? 'car_status_available' : 'car_status_unavailable').tr(),
            style: TextStyle(fontSize: 9.5.r, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}
