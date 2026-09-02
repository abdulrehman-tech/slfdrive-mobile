class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  // Driver-entity id (distinct from userId) — what bookings filter/reference as
  // driverId. Resolved from GET /api/Driver/{userId} and cached.
  static const String driverId = 'driver_id';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String userName = 'user_name';
  // Backend gender code (M/F/O). Cached from the login/profile user because the
  // Customer GET DTO doesn't return gender — used to prefill the edit form.
  static const String userGender = 'user_gender';
  static const String userProfileImage = 'user_profile_image';
  static const String userLat = 'user_lat';
  static const String userLon = 'user_lon';
  static const String userLocationLabel = 'user_location_label';
  static const String isLoggedIn = 'is_logged_in';
  static const String isVerified = 'is_verified';
  static const String verifiedBadgeDismissed = 'verified_badge_dismissed';
  
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String countryCode = 'country_code';
  
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  
  static const String fcmToken = 'fcm_token';
  static const String notificationsEnabled = 'notifications_enabled';
  // User id the stored [fcmToken] was last successfully registered for. Both are
  // written only on a 2xx from PUT /api/Auth/fcm-token, so a failed upload
  // naturally retries on the next resume instead of being assumed done.
  static const String fcmTokenRegisteredUserId = 'fcm_token_registered_user_id';
  // Stable per-install device identifier (ANDROID_ID / identifierForVendor),
  // resolved once via device_info_plus then cached — see core/utils/device_id.dart.
  static const String deviceId = 'device_id';
  // Pre-permission ("soft ask") sheet throttle: how many times it has been shown
  // and when it was last shown, so a declined prompt is never nagged.
  static const String pushPrimeCount = 'push_prime_count';
  static const String pushPrimeLastAt = 'push_prime_last_at';
  // Driver notification-channel preferences (local-only; no backend endpoint).
  static const String driverNotifPush = 'driver_notif_push';
  static const String driverNotifEmail = 'driver_notif_email';
  static const String driverNotifSms = 'driver_notif_sms';
  
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedCars = 'cached_cars';
  static const String cachedDrivers = 'cached_drivers';

  // Locally-persisted notification inbox (SharedPreferences, not secure storage —
  // non-sensitive and it grows). The backend has no notifications feed, so the
  // inbox is built from received pushes. [notifInboxPending] is an append-only
  // queue written ONLY by the FCM background isolate and drained ONLY by the UI
  // isolate; keeping it separate from [notifInbox] avoids a lost-update race
  // between the two isolates.
  static const String notifInbox = 'notif_inbox';
  static const String notifInboxPending = 'notif_inbox_pending';

  // Locally-persisted favourites (no backend endpoint).
  static const String favoriteCars = 'favorite_cars';
  static const String favoriteDrivers = 'favorite_drivers';
}
