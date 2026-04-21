import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'src/core/di/injection_container.dart';
import 'src/core/secrets/maps_loader.dart';
import 'src/presentation/providers/language_provider.dart';
import 'src/presentation/providers/role_provider.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/presentation/theme/app_theme.dart';
import 'src/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider.value(value: roleProvider),
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
