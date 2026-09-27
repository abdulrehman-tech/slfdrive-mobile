import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// "Version 1.0.4 (18)" footer shown at the end of the profile pages.
class AppVersionLabel extends StatelessWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snap) {
          final info = snap.data;
          if (info == null) return const SizedBox.shrink();
          return Text(
            'profile_version'.tr(namedArgs: {'version': '${info.version} (${info.buildNumber})'}),
            style: TextStyle(
              fontSize: 11.r,
              color: cs.onSurface.withValues(alpha: 0.35),
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    );
  }
}
