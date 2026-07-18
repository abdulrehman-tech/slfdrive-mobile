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
  // Driver notification-channel preferences (local-only; no backend endpoint).
  static const String driverNotifPush = 'driver_notif_push';
  static const String driverNotifEmail = 'driver_notif_email';
  static const String driverNotifSms = 'driver_notif_sms';
  
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedCars = 'cached_cars';
  static const String cachedDrivers = 'cached_drivers';

  // Locally-persisted favourites (no backend endpoint).
  static const String favoriteCars = 'favorite_cars';
  static const String favoriteDrivers = 'favorite_drivers';
}
