import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';

class DrawerHeaderSection extends StatelessWidget {
  final bool isDark;

  const DrawerHeaderSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = (auth.displayName?.trim().isNotEmpty ?? false) ? auth.displayName!.trim() : 'profile_guest_name'.tr();
    final email = (auth.displayEmail?.trim().isNotEmpty ?? false) ? auth.displayEmail!.trim() : 'guest@slfdrive.com';
    final avatarUrl = auth.avatarUrl;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'G';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.r, 56.r, 20.r, 20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10.r,
            top: -20.r,
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          Positioned(
            right: 30.r,
            bottom: -30.r,
            child: Container(
              width: 70.r,
              height: 70.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)),
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 58.r,
                    height: 58.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.r),
                        ),
                      ],
                    ),
                    child: avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl,
                              width: 58.r,
                              height: 58.r,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _initialBadge(initial),
                            ),
                          )
                        : _initialBadge(initial),
                  ),
                  Positioned(
                    bottom: 2.r,
                    right: 2.r,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'home_greeting'.tr(),
                    //   style: TextStyle(fontSize: 11.r, color: Colors.white60, fontWeight: FontWeight.w500),
                    // ),
                    // SizedBox(height: 3.r),
                    Text(
                      name,
                      style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.r),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 11.r,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _initialBadge(String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: const Color(0xFF0C2485)),
      ),
    );
  }
}
