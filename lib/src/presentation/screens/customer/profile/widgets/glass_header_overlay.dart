import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../provider/profile_provider.dart';

class GlassHeaderOverlay extends StatelessWidget {
  final bool isDark;
  const GlassHeaderOverlay({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    final scrollOffset = context.watch<ProfileProvider>().scrollOffset;

    final auth = context.watch<AuthProvider>();
    final name = (auth.displayName?.trim().isNotEmpty ?? false)
        ? auth.displayName!.trim()
        : 'profile_guest_name'.tr();
    final email = (auth.displayEmail?.trim().isNotEmpty ?? false)
        ? auth.displayEmail!.trim()
        : 'guest@slfdrive.com';
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : 'G';

    // Don't start fading in until most of the gradient card has scrolled away.
    const triggerStart = 120.0;
    const triggerEnd = 170.0;
    final t = ((scrollOffset - triggerStart) / (triggerEnd - triggerStart)).clamp(0.0, 1.0);

    return IgnorePointer(
      ignoring: t < 0.6,
      child: Opacity(
        opacity: t,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.fromLTRB(12.r, topPad + 6.r, 12.r, 10.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.74) : Colors.white.withValues(alpha: 0.82),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _SmallAvatar(initial: initial, avatarUrl: auth.avatarUrl),
                  SizedBox(width: 10.r),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 10.r,
                            color: cs.onSurface.withValues(alpha: 0.55),
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
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  final String initial;
  final String? avatarUrl;
  const _SmallAvatar({required this.initial, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF69FF47), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: avatarUrl != null
          ? ClipOval(
              child: Image.network(
                avatarUrl!,
                width: 36.r,
                height: 36.r,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _initial(),
              ),
            )
          : _initial(),
    );
  }

  Widget _initial() {
    return Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w900, color: const Color(0xFF0C2485)),
      ),
    );
  }
}
