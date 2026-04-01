# Theme Integration Example

## How to Use the Theme System in main.dart

Replace your current `main.dart` with this implementation:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/presentation/theme/app_theme.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/presentation/providers/language_provider.dart';
import 'src/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Lock to portrait mode (optional, remove for web/desktop)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Setup dependency injection
  await setupDependencyInjection();
  
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'AE'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(430, 932), // iPhone 14 Pro Max
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'SLF Drive',
                debugShowCheckedModeBanner: false,
                
                // Localization
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: languageProvider.locale,
                
                // Theme
                theme: AppTheme.lightTheme(languageProvider.fontFamily),
                darkTheme: AppTheme.darkTheme(languageProvider.fontFamily),
                themeMode: themeProvider.themeMode,
                
                // Home
                home: const MyHomePage(title: 'SLF Drive'),
              );
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Theme switcher
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          // Language switcher
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              context.read<LanguageProvider>().toggleLanguage();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'welcome'.tr(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            
            // Example gradient button
            Container(
              width: 200,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0C2485), Color(0xFF677EF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text('get_started'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Features Included

### ✅ Light & Dark Theme
- **Light Theme**: Deep Blue (#0C2485) primary color, white background
- **Dark Theme**: Light Blue (#677EF0) primary color, dark background (#121212)
- Automatic font switching based on language (OpenSans for English, Tajawal for Arabic)

### ✅ Theme Provider
- Persistent theme selection (saved to SharedPreferences)
- Three modes: Light, Dark, System
- Toggle between light/dark
- Animated theme switching

### ✅ Language Provider
- English (en-US) and Arabic (ar-AE) support
- Automatic font family switching
- Persistent language selection
- RTL support for Arabic

### ✅ Responsive Design
- ScreenUtil for responsive sizing
- Adapts to different screen sizes
- Works on mobile, tablet, desktop, and web

## Theme Components

### 1. Colors
```dart
// Light Theme
Primary: #0C2485 (Deep Blue)
Secondary: #677EF0 (Light Blue)
Background: #FAFAFA

// Dark Theme
Primary: #677EF0 (Light Blue)
Secondary: #0C2485 (Deep Blue)
Background: #121212
```

### 2. Gradient
```dart
const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF0C2485), Color(0xFF677EF0)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### 3. Typography
- Display: 32px, 28px, 24px (Bold)
- Headline: 22px, 20px, 18px (SemiBold)
- Title: 18px, 16px, 14px (SemiBold)
- Body: 16px, 14px, 12px (Regular)
- Label: 14px, 12px, 10px (SemiBold)

### 4. Components Styled
- ✅ AppBar (transparent with blur effect ready)
- ✅ Buttons (Elevated, Outlined, Text)
- ✅ Input Fields
- ✅ Cards
- ✅ Bottom Navigation Bar
- ✅ FAB
- ✅ Chips
- ✅ Dividers
- ✅ Icons

## Usage Examples

### Theme Switcher Widget
```dart
import 'package:provider/provider.dart';
import 'src/presentation/widgets/animated_theme_switcher.dart';

// In your AppBar or Settings
AnimatedThemeSwitcher()

// Or use the segmented button
ThemeModeSelector()
```

### Access Current Theme
```dart
// Check if dark mode
final isDark = Theme.of(context).brightness == Brightness.dark;

// Get theme colors
final primaryColor = Theme.of(context).colorScheme.primary;
final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

// Get text styles
final headlineStyle = Theme.of(context).textTheme.headlineLarge;
```

### Gradient Button
```dart
import 'src/presentation/widgets/gradient_button.dart';

GradientButton(
  text: 'Book Now',
  onPressed: () {},
  width: 200,
  height: 56,
)
```

## Next Steps

1. **Update main.dart** with the example code above
2. **Add fonts** to `assets/fonts/` folders
3. **Test theme switching** in both light and dark modes
4. **Test language switching** between English and Arabic
5. **Customize** theme colors if needed

## Notes

- Theme persists across app restarts
- Language persists across app restarts
- System theme mode follows device settings
- All Material 3 components are styled
- RTL support is automatic for Arabic
