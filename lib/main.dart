import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/presentation/theme/app_theme.dart';
import 'src/presentation/routes/app_router.dart';
import 'src/presentation/widgets/responsive_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

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
      child: const MyApp(),
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
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return ResponsiveWrapper(
                child: MaterialApp.router(
                  title: 'SLF Drive',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme(_getFontFamily(context.locale)),
                  darkTheme: AppTheme.darkTheme(_getFontFamily(context.locale)),
                  themeMode: themeProvider.themeMode,
                  locale: context.locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  routerConfig: AppRouter.router,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
