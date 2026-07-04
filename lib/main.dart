import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'src/core/data/repositories/auth_repository.dart';
import 'src/core/di/injection_container.dart';
import 'src/core/network/media_http_override.dart';
import 'src/core/secrets/maps_loader.dart';
import 'src/core/services/session_manager.dart';
import 'src/presentation/providers/auth_provider.dart';
import 'src/presentation/providers/location_provider.dart';
import 'src/presentation/providers/role_provider.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/presentation/screens/customer/favorites/provider/favorites_provider.dart';
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

 void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(_applyHighRefreshRate());
  await EasyLocalization.ensureInitialized();

  // Trust the backend's self-signed cert for the media host so Image.network
  // can load profile photos / documents (no-op on web). Mirrors the Dio bypass.
  applySelfSignedMediaOverride();

  // Set up DI container (currently only registers FlutterSecureStorage).
  await setupDependencyInjection();

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

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  late final SessionManager _sessionManager;
  bool _handlingExpiry = false;

  @override
  void initState() {
    super.initState();
    _sessionManager = getIt<SessionManager>();
    _sessionManager.expiredSignal.addListener(_onSessionExpired);
  }

  @override
  void dispose() {
    _sessionManager.expiredSignal.removeListener(_onSessionExpired);
    super.dispose();
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
        );
      },
    );
  }
}
