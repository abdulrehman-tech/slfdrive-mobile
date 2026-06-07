import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'src/core/data/repositories/auth_repository.dart';
import 'src/core/di/injection_container.dart';
import 'src/core/network/media_http_override.dart';
import 'src/core/secrets/maps_loader.dart';
import 'src/presentation/providers/auth_provider.dart';
import 'src/presentation/providers/location_provider.dart';
import 'src/presentation/providers/role_provider.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/presentation/screens/customer/profile/corporate/provider/corporate_provider.dart';
import 'src/presentation/theme/app_theme.dart';
import 'src/presentation/routes/app_router.dart';
 void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          ChangeNotifierProvider(create: (_) => CorporateProvider()),
          ChangeNotifierProvider(
            create: (_) => LocationProvider(getIt<AuthRepository>(), getIt<FlutterSecureStorage>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
