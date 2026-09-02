import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'src/core/data/repositories/auth_repository.dart';
import 'src/core/config/app_environment.dart';
import 'src/core/di/injection_container.dart';
import 'firebase_options.dart';
import 'src/core/network/self_signed_tls.dart';
import 'src/core/secrets/maps_loader.dart';
import 'src/core/services/push_background_handler.dart';
import 'src/core/services/push_messaging_service.dart';
import 'src/core/services/session_manager.dart';
import 'src/presentation/providers/auth_provider.dart';
import 'src/presentation/providers/location_provider.dart';
import 'src/presentation/providers/role_provider.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/presentation/screens/customer/favorites/provider/favorites_provider.dart';
import 'src/presentation/screens/customer/notifications/provider/notifications_provider.dart';
import 'src/presentation/routes/push_routes.dart';
import 'src/presentation/utils/platform_utils.dart';
import 'src/presentation/theme/app_theme.dart';
import 'src/presentation/routes/app_router.dart';
/// Opt into the device's highest refresh rate (90/120 Hz) on Android so
/// scrolling runs at full frame rate. No-op on web/iOS; never blocks startup
/// and swallows failures on panels that don't support mode switching.
Future<void> _applyHighRefreshRate() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (e) {
    debugPrint('High refresh rate unavailable: $e');
  }
}

/// Brings up Firebase and registers the FCM background isolate handler.
///
/// Returns false when initialisation fails so [PushMessagingService] can no-op:
/// a fresh clone without `google-services.json` / `GoogleService-Info.plist`
/// must still run the rest of the app. Web is skipped entirely (no service
/// worker or VAPID key is configured).
Future<bool> _initFirebase() async {
  if (!PlatformUtils.isMobile) return false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Must be registered before runApp, with the bare top-level tear-off.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    return true;
  } catch (e) {
    debugPrint('⚠️ Firebase init failed — push notifications disabled: $e');
    return false;
  }
}

 void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _initFirebase();
  unawaited(_applyHighRefreshRate());
  await EasyLocalization.ensureInitialized();

  // UAT builds talk to a self-signed host: trust it for image loading too
  // (Dio is handled in ApiClient). No-op for prod and on web.
  applySelfSignedHttpOverrides();
  if (!AppEnvironment.current.isProd) {
    debugPrint('⚠️ APP_ENV=${AppEnvironment.current.name} → ${AppEnvironment.current.apiBaseUrl}');
  }

  // Set up DI container (currently only registers FlutterSecureStorage).
  await setupDependencyInjection();

  // Push: hydrate the inbox and wire FCM. Both are fire-and-forget so neither
  // delays the first frame — same treatment as the Maps SDK below.
  final notifications = getIt<NotificationsProvider>();
  final push = getIt<PushMessagingService>()
    ..firebaseReady = firebaseReady
    ..onMessageReceived = notifications.ingest;
  unawaited(notifications.load());
  unawaited(push.init());

  // Inject Google Maps JS SDK on web (no-op elsewhere). Non-blocking for the
  // UI — map widgets will await the same future lazily if needed.
  unawaited(ensureGoogleMapsLoaded());

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Hydrate the role from secure storage before the first frame so GoRouter's
  // redirect guard can see it on cold boot.
  final roleProvider = RoleProvider(getIt<FlutterSecureStorage>());
  await roleProvider.load();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'AE'),
        Locale('hi', 'IN'),
        Locale('ur', 'PK'),
        Locale('de', 'DE'),
        Locale('es', 'ES'),
        Locale('ru', 'RU'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      // Back-fill keys missing from a locale with the English text instead of
      // rendering the raw key (several locales lag behind en-US/ar-AE).
      useFallbackTranslations: true,
      startLocale: const Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: roleProvider),
          ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
          ChangeNotifierProvider(
            create: (_) => LocationProvider(getIt<AuthRepository>(), getIt<FlutterSecureStorage>()),
          ),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider.value(value: notifications),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  late final SessionManager _sessionManager;
  late final PushMessagingService _push;
  bool _handlingExpiry = false;

  @override
  void initState() {
    super.initState();
    _sessionManager = getIt<SessionManager>();
    _sessionManager.expiredSignal.addListener(_onSessionExpired);

    _push = getIt<PushMessagingService>();
    _push.tapSignal.addListener(_drainPushTaps);
    WidgetsBinding.instance.addObserver(this);
    // A cold-start tap is queued by PushMessagingService.init() before this
    // listener exists, so the signal alone would miss it. Splash still owns the
    // first navigation — handlePushTap no-ops while the router is on '/'.
    WidgetsBinding.instance.addPostFrameCallback((_) => _drainPushTaps());
  }

  @override
  void dispose() {
    _sessionManager.expiredSignal.removeListener(_onSessionExpired);
    _push.tapSignal.removeListener(_drainPushTaps);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Re-check permission (the user may have changed it in system Settings) and
    // fold in anything the FCM background isolate queued while we were away.
    unawaited(_push.onAppResumed());
    unawaited(getIt<NotificationsProvider>().drainBackgroundQueue());
    _drainPushTaps();
  }

  /// Routes queued notification taps. Payloads that can't be handled yet (no
  /// context, or the router is still on splash) stay queued for the next drain.
  void _drainPushTaps() {
    while (_push.hasPendingTap) {
      final payload = _push.takePendingTap();
      if (payload == null) return;
      if (!handlePushTap(payload)) {
        _push.requeueTap(payload);
        return;
      }
    }
  }

  /// Fired when the auth interceptor gives up refreshing an expired token.
  /// Clears the session, tells the user, and routes to auth. Guarded so a burst
  /// of concurrent 401s (many in-flight requests) triggers exactly one logout.
  Future<void> _onSessionExpired() async {
    if (_handlingExpiry) return;
    _handlingExpiry = true;
    try {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        // Tokens are already wiped by the interceptor, so logout() skips the
        // network revoke and just clears local state (no 401 loop). Capture the
        // providers before awaiting so we don't reach across the async gap.
        final auth = ctx.read<AuthProvider>();
        final role = ctx.read<RoleProvider>();
        try {
          await auth.logout();
          await role.clear();
        } catch (_) {}
      }
      _messengerKey.currentState
        ?..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('session_expired_message'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      AppRouter.router.go('/auth');
    } finally {
      _handlingExpiry = false;
    }
  }

  String _getFontFamily(Locale locale) {
    if (locale.languageCode == 'ar' || locale.languageCode == 'ur') {
      return 'Tajawal';
    }
    return 'OpenSans';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'SLF Drive',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: _messengerKey,
          theme: AppTheme.lightTheme(_getFontFamily(context.locale)),
          darkTheme: AppTheme.darkTheme(_getFontFamily(context.locale)),
          themeMode: themeProvider.themeMode,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          routerConfig: AppRouter.router,
          // Tap anywhere outside a text field to dismiss the keyboard (iOS has
          // no back button to close it). Sits above the Navigator, so every
          // route and modal sheet is covered; translucent hit-testing lets
          // interactive widgets win the gesture arena as usual.
          builder: (context, child) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child,
          ),
        );
      },
    );
  }
}
