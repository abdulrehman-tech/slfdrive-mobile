import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../providers/auth_provider.dart';

/// Shows the driver's approval status on the dashboard: an amber "pending
/// review" banner until an admin verifies the account, then a green "verified"
/// confirmation. Driven by [AuthProvider.isVerified].
///
/// On mount it refreshes the status from the server (`GET /api/Driver/{id}`),
/// so admin approval is reflected without requiring a re-login. The verified
/// confirmation can be dismissed (X) and stays dismissed across launches; the
/// pending banner is not dismissible.
class DriverVerificationBanner extends StatefulWidget {
  final bool isDark;

  const DriverVerificationBanner({super.key, required this.isDark});

  @override
  State<DriverVerificationBanner> createState() => _DriverVerificationBannerState();
}

class _DriverVerificationBannerState extends State<DriverVerificationBanner> {
  final FlutterSecureStorage _storage = getIt<FlutterSecureStorage>();
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _loadDismissed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().refreshDriverStatus();
    });
  }

  Future<void> _loadDismissed() async {
    final v = await _storage.read(key: StorageKeys.verifiedBadgeDismissed);
    if (mounted && v == 'true') setState(() => _dismissed = true);
  }

  Future<void> _dismiss() async {
    await _storage.write(key: StorageKeys.verifiedBadgeDismissed, value: 'true');
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final verified = context.select<AuthProvider, bool>((a) => a.isVerified);

    // The verified confirmation is dismissible; once dismissed, stay hidden.
    if (verified && _dismissed) return const SizedBox.shrink();

    final Color accent = verified ? const Color(0xFF2E7D32) : const Color(0xFFF9A825);
    final IconData icon = verified ? Iconsax.verify : Iconsax.clock;
    final String title = verified ? 'driver_status_verified_title'.tr() : 'driver_status_pending_title'.tr();
    final String message = verified ? 'driver_status_verified_msg'.tr() : 'driver_status_pending_msg'.tr();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(icon, color: accent, size: 22.r),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.r,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                  ),
                ),
                SizedBox(height: 2.r),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.r,
                    height: 1.35,
                    color: isDark ? Colors.white70 : const Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),
          if (verified)
            GestureDetector(
              onTap: _dismiss,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(left: 8.r),
                child: Icon(Icons.close, size: 18.r, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
              ),
            ),
        ],
      ),
    );
  }
}
