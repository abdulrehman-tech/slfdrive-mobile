import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../constants/color_constants.dart';
import '../../constants/storage_keys.dart';
import '../../core/di/injection_container.dart';
import '../../core/services/push_messaging_service.dart';

/// How many times the pre-permission sheet may ever be shown.
const int _maxPrimeAttempts = 3;

/// Minimum gap between showings, so a "Not now" is never nagged.
const Duration _primeCooldown = Duration(days: 3);

/// Shows the pre-permission ("soft ask") sheet if now is an appropriate moment,
/// and only fires the OS dialog when the user actively opts in.
///
/// Why the extra step rather than calling `requestPermission()` directly: iOS
/// grants exactly one system prompt per install, and both Apple's HIG and Play
/// policy treat an unexplained prompt as a dark pattern. A declined *pre*-prompt
/// is recoverable; a declined OS prompt is not.
///
/// Call it from a moment of genuine intent — see the call sites in the driver
/// home and the booking-success step. Returns true when the user ends up
/// authorised.
Future<bool> maybePrimePushPermission(
  BuildContext context, {
  required bool isDriver,
}) async {
  // A signed-out user (guest, or pre-login) can't register a token anyway, and
  // iOS grants exactly one system prompt per install — don't spend it on them.
  final storage = getIt<FlutterSecureStorage>();
  final accessToken = await storage.read(key: StorageKeys.accessToken);
  if (accessToken == null || accessToken.isEmpty) return false;

  final push = getIt<PushMessagingService>();
  final status = await push.currentStatus();

  // Nothing to ask for: already granted, or the platform can't deliver.
  if (status == PushAuthStatus.authorized ||
      status == PushAuthStatus.provisional) {
    return true;
  }
  // Already refused at OS level — the prompt will not reappear, so asking again
  // is pure noise. The profile toggle is the recovery path.
  if (status != PushAuthStatus.notDetermined) return false;

  if (!await _shouldPrime(storage)) return false;
  if (!context.mounted) return false;

  final allow = await _showPrimeSheet(context, isDriver: isDriver);
  await _recordPrimeShown(storage);
  if (allow != true) return false;

  final result = await push.requestSystemPermission();
  return result == PushAuthStatus.authorized ||
      result == PushAuthStatus.provisional;
}

Future<bool> _shouldPrime(FlutterSecureStorage storage) async {
  final count =
      int.tryParse(await storage.read(key: StorageKeys.pushPrimeCount) ?? '') ??
          0;
  if (count >= _maxPrimeAttempts) return false;

  final lastRaw = await storage.read(key: StorageKeys.pushPrimeLastAt);
  final last = lastRaw == null ? null : DateTime.tryParse(lastRaw);
  if (last != null && DateTime.now().difference(last) < _primeCooldown) {
    return false;
  }
  return true;
}

Future<void> _recordPrimeShown(FlutterSecureStorage storage) async {
  final count =
      int.tryParse(await storage.read(key: StorageKeys.pushPrimeCount) ?? '') ??
          0;
  await storage.write(
    key: StorageKeys.pushPrimeCount,
    value: '${count + 1}',
  );
  await storage.write(
    key: StorageKeys.pushPrimeLastAt,
    value: DateTime.now().toIso8601String(),
  );
}

Future<bool?> _showPrimeSheet(
  BuildContext context, {
  required bool isDriver,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.r, 20.r, 24.r, 24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.r,
              height: 4.r,
              margin: EdgeInsets.only(bottom: 20.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.notification_copy,
                  color: secondaryColor, size: 30.r),
            ),
            SizedBox(height: 18.r),
            Text(
              (isDriver ? 'push_prime_title_driver' : 'push_prime_title').tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.r,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8.r),
            Text(
              (isDriver ? 'push_prime_body_driver' : 'push_prime_body').tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.r,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 16.r),
            _PrimePoint(
              icon: Iconsax.calendar_tick_copy,
              labelKey: isDriver
                  ? 'push_prime_point_trips'
                  : 'push_prime_point_bookings',
              isDark: isDark,
            ),
            _PrimePoint(
              icon: Iconsax.clock_copy,
              labelKey: 'push_prime_point_reminders',
              isDark: isDark,
            ),
            _PrimePoint(
              icon: Iconsax.discount_shape_copy,
              labelKey: 'push_prime_point_offers',
              isDark: isDark,
            ),
            SizedBox(height: 22.r),
            Row(
              children: [
                // Same size and weight as "Allow" — a decline that reads as a
                // second-class option is what gets a priming screen rejected.
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'push_prime_later'.tr(),
                      style: TextStyle(
                        fontSize: 14.r,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'push_prime_allow'.tr(),
                      style: TextStyle(
                          fontSize: 14.r,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PrimePoint extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final bool isDark;

  const _PrimePoint({
    required this.icon,
    required this.labelKey,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.r),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: secondaryColor),
          SizedBox(width: 10.r),
          Expanded(
            child: Text(
              labelKey.tr(),
              style: TextStyle(
                fontSize: 12.r,
                height: 1.35,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the user tries to switch notifications on but the OS has them
/// blocked. The system prompt will not reappear, so the only route back is
/// Settings.
Future<void> showPushBlockedSheet(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final open = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.r, 20.r, 24.r, 24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.r,
              height: 4.r,
              margin: EdgeInsets.only(bottom: 20.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.notification_bing_copy,
                  color: secondaryColor, size: 30.r),
            ),
            SizedBox(height: 18.r),
            Text(
              'push_blocked_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.r,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8.r),
            Text(
              'push_blocked_body'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.r,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 22.r),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'cancel'.tr(),
                      style: TextStyle(
                        fontSize: 14.r,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'push_blocked_open_settings'.tr(),
                      style: TextStyle(
                          fontSize: 14.r,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (open == true) await getIt<PushMessagingService>().openSystemSettings();
}
