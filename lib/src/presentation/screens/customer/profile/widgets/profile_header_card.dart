import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileHeaderCard extends StatelessWidget {
  final bool isDark;
  final bool rounded;
  const ProfileHeaderCard({super.key, required this.isDark, this.rounded = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final topPad = rounded ? 0.0 : MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20.r, topPad + 16.r, 20.r, 20.r),
      decoration: BoxDecoration(
        borderRadius: rounded ? BorderRadius.circular(22.r) : null,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: rounded
            ? [BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 18.r, offset: Offset(0, 8.r))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2.5),
            ),
            child: Center(
              child: Text(
                'G',
                style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.w900, color: const Color(0xFF0C2485)),
              ),
            ),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'profile_guest_name'.tr(),
                  style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.w800, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.r),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 3.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFD54F)]),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.medal_star_copy, size: 11.r, color: const Color(0xFF8B5A00)),
                      SizedBox(width: 4.r),
                      Text(
                        'profile_tier_gold'.tr(),
                        style: TextStyle(fontSize: 10.r, color: const Color(0xFF5D3A00), fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'guest@slfdrive.com',
                  style: TextStyle(fontSize: 11.r, color: Colors.white.withValues(alpha: 0.75)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Icon(Iconsax.edit_copy, size: 16.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
