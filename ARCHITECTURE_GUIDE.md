# Absher App - Architecture & Structure Guide

This document provides a comprehensive overview of the Absher application's architecture, folder structure, packages, and design patterns. Use this as a reference when creating new Flutter applications with similar architecture.

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Folder Structure](#folder-structure)
4. [Dependencies & Packages](#dependencies--packages)
5. [Core Components](#core-components)
6. [Design Patterns](#design-patterns)
7. [Performance Optimizations](#performance-optimizations)
8. [Firebase Integration](#firebase-integration)
9. [Localization](#localization)
10. [Theming](#theming)
11. [Navigation](#navigation)
12. [Best Practices](#best-practices)

---

## 🎯 Project Overview

**App Name:** Absher - Al Mader Application  
**Version:** 1.0.2+15  
**SDK:** Flutter ^3.9.2  
**Architecture:** Clean Architecture with Provider State Management  
**Platforms:** Android, iOS, Web, Linux, macOS, Windows

---

## 🏗️ Architecture Pattern

The app follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, Providers)          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Domain Layer (Implicit)         │
│  (Business Logic in Providers)          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│            Data Layer                   │
│  (Repositories, DataSources, Models)    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         External Services               │
│  (API, Firebase, Local Storage)         │
└─────────────────────────────────────────┘
```

### Key Architectural Principles:

1. **Dependency Injection** - Using `get_it` for service locator pattern
2. **State Management** - Provider pattern for reactive state
3. **Repository Pattern** - Abstraction over data sources
4. **Single Responsibility** - Each class has one clear purpose
5. **Dependency Inversion** - High-level modules don't depend on low-level modules

---

## 📁 Folder Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
└── src/
    ├── constants/                     # App-wide constants
    │   ├── color_constants.dart       # Color palette
    │   ├── endpoints.dart             # API endpoints
    │   ├── icon_constants.dart        # Icon paths
    │   ├── image_constants.dart       # Image asset paths
    │   ├── lottie_constants.dart      # Lottie animation paths
    │   ├── storage_keys.dart          # Secure storage keys
    │   └── url_constants.dart         # External URLs
    │
    ├── core/                          # Core business logic
    │   ├── config/                    # App configuration
    │   ├── data/                      # Data layer
    │   │   ├── datasources/           # Remote data sources
    │   │   │   ├── auth_remote_datasource.dart
    │   │   │   ├── country_remote_datasource.dart
    │   │   │   ├── user_remote_datasource.dart
    │   │   │   ├── newspaper_remote_datasource.dart
    │   │   │   └── ad_posting_remote_datasource.dart
    │   │   ├── repositories/          # Repository implementations
    │   │   │   ├── auth_repository.dart
    │   │   │   ├── country_repository.dart
    │   │   │   ├── user_repository.dart
    │   │   │   ├── newspaper_repository.dart
    │   │   │   └── ad_posting_repository.dart
    │   │   └── countries_data.dart    # Static country data
    │   │
    │   ├── di/                        # Dependency Injection
    │   │   └── injection_container.dart
    │   │
    │   ├── errors/                    # Error handling
    │   │
    │   ├── models/                    # Data models
    │   │   ├── ad/                    # Ad-related models
    │   │   ├── auth/                  # Authentication models
    │   │   ├── country/               # Country models
    │   │   ├── newspaper/             # Newspaper models
    │   │   ├── payment/               # Payment models
    │   │   ├── user/                  # User models
    │   │   └── language_model.dart
    │   │
    │   ├── network/                   # Network layer
    │   │   ├── api_client.dart        # Dio HTTP client
    │   │   ├── api_interceptor.dart   # Request/response interceptor
    │   │   ├── api_response.dart      # API response wrapper
    │   │   └── auth_interceptor.dart  # Auth token interceptor
    │   │
    │   ├── services/                  # Core services
    │   │   ├── firebase_service.dart
    │   │   └── notification_service.dart
    │   │
    │   └── utils/                     # Core utilities
    │
    └── presentation/                  # UI layer
        ├── providers/                 # State management
        │   ├── auth_provider.dart
        │   ├── theme_provider.dart
        │   ├── newspaper_provider.dart
        │   └── ad_posting_provider.dart
        │
        ├── routes/                    # Navigation
        │   └── app_router.dart        # GoRouter configuration
        │
        ├── screens/                   # App screens
        │   ├── auth/                  # Authentication screens
        │   │   ├── login/
        │   │   ├── otp/
        │   │   ├── role_selection/
        │   │   └── verification_success/
        │   ├── chats/
        │   ├── help/
        │   ├── home/
        │   ├── language_selection/
        │   ├── my_ads/
        │   ├── news_agencies/
        │   ├── newspapers/
        │   ├── notifications/
        │   ├── onboarding/
        │   ├── payments/
        │   ├── post_ad/
        │   ├── profile/
        │   └── splash/
        │
        ├── theme/                     # App theming
        │   └── app_theme.dart
        │
        ├── utils/                     # UI utilities
        │   ├── animated_route.dart
        │   ├── download_service.dart
        │   ├── fade_animation.dart
        │   ├── performance_utils.dart
        │   └── snackbar_utils.dart
        │
        └── widgets/                   # Reusable widgets
            ├── access_control_sheet.dart
            ├── animated_theme_switcher.dart
            ├── country_picker_sheet.dart
            ├── country_selection_sheet.dart
            ├── glass_app_bar.dart
            ├── glass_bottom_nav_bar.dart
            ├── glass_container.dart
            ├── glass_drawer.dart
            ├── image_source_picker_sheet.dart
            ├── omr_currency_symbol.dart
            └── section_header.dart

assets/
├── fonts/                             # Custom fonts
│   ├── Open_Sans/                     # English font
│   └── Tajawal/                       # Arabic font
├── icons/                             # SVG icons
├── images/                            # PNG/JPG images
├── lottie/                            # Lottie animations
└── translations/                      # i18n JSON files
    ├── en-US.json
    └── ar-AE.json
```

---

## 📦 Dependencies & Packages

### Core Dependencies

```yaml
# State Management & DI
provider: ^6.1.5+1              # State management
get_it: ^8.2.0                  # Dependency injection

# Navigation
go_router: ^14.6.2              # Declarative routing

# Network
dio: ^5.9.0                     # HTTP client
connectivity_plus: ^7.0.0       # Network connectivity

# Storage
flutter_secure_storage: ^9.2.4  # Encrypted storage
flutter_dotenv: ^5.2.1          # Environment variables
flutter_cache_manager: ^3.4.1   # Cache management

# UI Components
flutter_screenutil: ^5.9.3      # Responsive sizing
flutter_svg: ^2.2.3             # SVG support
skeletonizer: ^2.1.0            # Skeleton loading
cached_network_image: ^3.4.1    # Image caching
flutter_easyloading: ^3.0.5     # Loading indicators
iconsax_flutter: ^1.0.1         # Modern icons
lottie: ^3.3.2                  # Lottie animations

# Localization
easy_localization: ^3.0.8       # i18n support
intl: ^0.20.2                   # Internationalization

# PDF Viewer
syncfusion_flutter_pdfviewer: ^28.2.7

# Firebase
firebase_core: ^3.13.0
firebase_analytics: ^11.4.6
firebase_crashlytics: ^4.3.6
firebase_messaging: ^15.2.5
firebase_performance: ^0.10.0+10
flutter_local_notifications: ^18.0.1

# Utilities
url_launcher: ^6.3.1            # Open URLs
share_plus: ^10.1.4             # Share content
gal: ^2.3.0                     # Gallery access
package_info_plus: ^8.3.1       # App info
path_provider: ^2.1.5           # File paths
permission_handler: ^12.0.1     # Permissions
image_picker: ^1.2.0            # Pick images
country_code_picker: ^3.4.1     # Country codes
pinput: ^6.0.1                  # OTP input
flutter_displaymode: ^0.7.0     # High refresh rate
file_picker: ^8.0.0+1           # File picker
clarity_flutter: ^1.7.1         # Microsoft Clarity analytics
```

### Dev Dependencies

```yaml
flutter_test:
  sdk: flutter
flutter_lints: ^5.0.0
flutter_launcher_icons: ^0.14.4
flutter_native_splash: ^2.4.7
```

---

## 🔧 Core Components

### 1. Dependency Injection (`injection_container.dart`)

```dart
final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Firebase Services
  getIt.registerSingleton<FirebaseService>(FirebaseService.instance);
  getIt.registerSingleton<NotificationService>(NotificationService.instance);

  // Core
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true)
    ),
  );

  // Network
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<FlutterSecureStorage>())
  );

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>())
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>())
  );

  // Providers
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      getIt<AuthRepository>(),
      getIt<FlutterSecureStorage>(),
      getIt<UserRepository>()
    ),
  );
}
```

### 2. API Client (`api_client.dart`)

- Built on Dio
- Includes interceptors for auth and logging
- Handles token refresh
- Error handling and retry logic
- Base URL from environment variables

### 3. Repository Pattern

**Abstract Repository:**
```dart
abstract class AuthRepository {
  Future<ApiResponse<LoginResponse>> login(String phone, String countryCode);
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(String phone, String otp);
}
```

**Implementation:**
```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  AuthRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<ApiResponse<LoginResponse>> login(String phone, String countryCode) {
    return remoteDataSource.login(phone, countryCode);
  }
}
```

### 4. Provider Pattern

```dart
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> login(String phone, String countryCode) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _authRepository.login(phone, countryCode);
      // Handle response
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 🎨 Design Patterns

### 1. **Glassmorphism UI**

All screens use a glassy design with backdrop blur effects:

- `GlassAppBar` - Transparent app bar with blur
- `GlassBottomNavBar` - Bottom navigation with glass effect
- `GlassContainer` - Reusable glass container widget
- `GlassDrawer` - Side drawer with glass effect

**Performance Note:** Use `enableBlur: false` in scrollable content for better performance.

### 2. **Responsive Design**

Using `flutter_screenutil` for responsive sizing:

```dart
ScreenUtilInit(
  designSize: const Size(430, 932),  // iPhone 14 Pro Max
  splitScreenMode: true,
  minTextAdapt: true,
  builder: (_, child) => MaterialApp(...)
)
```

### 3. **Localization**

Using `easy_localization` with JSON files:

```dart
// In code
Text('welcome_message'.tr())

// In JSON (en-US.json)
{
  "welcome_message": "Welcome to Absher"
}
```

**Supported Locales:**
- English (en-US)
- Arabic (ar-AE)

**Font Switching:**
```dart
final fontFamily = currentLocale.languageCode == 'ar' ? 'Tajawal' : 'OpenSans';
```

### 4. **Theme Management**

Dynamic theme switching with Provider:

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
      ? ThemeMode.dark 
      : ThemeMode.light;
    notifyListeners();
  }
}
```

---

## ⚡ Performance Optimizations

### 1. **High Refresh Rate Support**

Automatically enables 90Hz/120Hz on supported Android devices:

```dart
Future<void> _setHighRefreshRate() async {
  final modes = await FlutterDisplayMode.supported;
  DisplayMode highestMode = modes.first;
  for (final mode in modes) {
    if (mode.refreshRate > highestMode.refreshRate) {
      highestMode = mode;
    }
  }
  await FlutterDisplayMode.setPreferredMode(highestMode);
}
```

### 2. **Scroll Performance**

```dart
physics: const BouncingScrollPhysics(
  decelerationRate: ScrollDecelerationRate.fast,
)
```

### 3. **Repaint Boundaries**

Wrap major sections in scrollable lists:

```dart
RepaintBoundary(
  child: YourSection(...),
)
```

### 4. **Release Mode Optimizations**

```dart
if (kReleaseMode) {
  debugPrint = (String? message, {int? wrapWidth}) {};
}
```

### 5. **Performance Rules for Scrollable Content**

**AVOID:**
- `BackdropFilter` - causes severe lag
- `ShaderMask` - very expensive
- `AnimatedContainer` - causes jank during scroll
- Double animations

**USE:**
- `RepaintBoundary` around major sections
- `const` constructors wherever possible
- Simple `Container` with conditional styling
- `BouncingScrollPhysics` for smooth scrolling

---

## 🔥 Firebase Integration

### Services Initialized:

1. **Firebase Analytics** - User behavior tracking
2. **Firebase Crashlytics** - Crash reporting
3. **Firebase Performance** - Performance monitoring
4. **Firebase Messaging (FCM)** - Push notifications
5. **Local Notifications** - In-app notifications

### Initialization Flow:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  // Initialize Firebase services
  await FirebaseService.instance.initialize();
  
  // Initialize notification service
  await NotificationService.instance.initialize();
  
  runApp(MyApp());
}
```

### Analytics Observer:

```dart
GoRouter(
  observers: [FirebaseService.instance.analyticsObserver],
  // routes...
)
```

---

## 🌍 Localization

### Setup:

```dart
EasyLocalization(
  path: 'assets/translations',
  supportedLocales: const [
    Locale('en', 'US'),
    Locale('ar', 'AE'),
  ],
  fallbackLocale: const Locale('en', 'US'),
  child: MyApp(),
)
```

### Usage:

```dart
// Simple translation
Text('key'.tr())

// With parameters
Text('welcome_user'.tr(args: ['John']))

// Plural
Text('items_count'.plural(5))

// Change language
context.setLocale(Locale('ar', 'AE'))
```

### Translation Files:

- `assets/translations/en-US.json`
- `assets/translations/ar-AE.json`

---

## 🎨 Theming

### Color Palette (`color_constants.dart`)

```dart
const Color primaryColor = Color(0xFFFFD700);      // Gold
const Color primaryColorDark = Color(0xFFB8860B);  // Dark Gold
const Color grayColor = Color(0xFF9E9E9E);
const Color errorColor = Color(0xFFD32F2F);
```

### Theme Structure:

- **Light Theme** - White background (#FFFFFA)
- **Dark Theme** - Dark background (#242323)
- **Material 3** - Modern design system
- **Custom Fonts** - OpenSans (EN), Tajawal (AR)

### Page Transitions:

```dart
PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  },
)
```

---

## 🧭 Navigation

### GoRouter Configuration:

```dart
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  observers: [FirebaseService.instance.analyticsObserver],
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const HomeScreen(),
        transitionsBuilder: _slideTransition,
      ),
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(),
);
```

### Navigation Methods:

```dart
// Push
context.push(AppRoutes.home);

// Push with data
context.push(AppRoutes.detail, extra: myData);

// Replace
context.go(AppRoutes.login);

// Pop
context.pop();
```

### Custom Transitions:

- **Fade** - For splash, auth screens
- **Slide** - For forward navigation (RTL-aware)

---

## 📱 App Initialization Flow

```
main()
  ↓
WidgetsFlutterBinding.ensureInitialized()
  ↓
Load .env file
  ↓
Initialize Firebase
  ↓
Initialize EasyLocalization
  ↓
Lock to Portrait
  ↓
Set High Refresh Rate (Android)
  ↓
Setup Dependency Injection
  ↓
Initialize Firebase Services
  ↓
Initialize Notification Service
  ↓
Disable debug prints (Release)
  ↓
Initialize Microsoft Clarity
  ↓
runApp(MyApp)
```

---

## 🛡️ Best Practices

### 1. **Environment Variables**

Always use `.env` file for sensitive data:

```env
API_BASE_URL=https://api.example.com
GOOGLE_MAPS_API_KEY=your_key
```

Never commit `.env` to version control!

### 2. **Secure Storage**

Use `flutter_secure_storage` for tokens and sensitive data:

```dart
await storage.write(key: 'auth_token', value: token);
final token = await storage.read(key: 'auth_token');
```

### 3. **Error Handling**

Always wrap API calls in try-catch:

```dart
try {
  final response = await repository.getData();
  // Handle success
} catch (e) {
  // Handle error
  if (e is DioException) {
    // Network error
  }
}
```

### 4. **Loading States**

Always show loading indicators:

```dart
if (isLoading) {
  return const CircularProgressIndicator();
}
```

### 5. **Null Safety**

Use null-aware operators:

```dart
final name = user?.name ?? 'Guest';
```

### 6. **Const Constructors**

Use `const` for better performance:

```dart
const Text('Hello')
const SizedBox(height: 16)
```

### 7. **Asset Organization**

Group assets by type:
- `assets/images/` - PNG/JPG images
- `assets/icons/` - SVG icons
- `assets/lottie/` - Lottie animations
- `assets/fonts/` - Custom fonts
- `assets/translations/` - i18n files

### 8. **Code Organization**

- One screen per folder
- Group related widgets
- Keep files under 500 lines
- Use meaningful names

### 9. **State Management**

- Use Provider for app-wide state
- Keep providers focused (single responsibility)
- Don't overuse `notifyListeners()`

### 10. **Performance**

- Use `RepaintBoundary` for complex widgets
- Avoid expensive operations in build()
- Use `const` constructors
- Lazy load images with `cached_network_image`

---

## 🚀 Getting Started with This Architecture

### 1. **Clone the Structure**

Create the folder structure as shown above.

### 2. **Add Dependencies**

Copy the dependencies from `pubspec.yaml`.

### 3. **Setup Firebase**

```bash
flutterfire configure
```

### 4. **Create .env File**

Copy `.env.example` to `.env` and fill in values.

### 5. **Setup Dependency Injection**

Create `injection_container.dart` and register services.

### 6. **Create Base Components**

- API Client
- Repositories
- Providers
- Theme
- Router

### 7. **Add Assets**

- Fonts
- Icons
- Images
- Translations

### 8. **Run the App**

```bash
flutter pub get
flutter run
```

---

## 📝 Additional Notes

### Platform-Specific Configuration

**Android:**
- Min SDK: 21
- High refresh rate support
- Encrypted shared preferences

**iOS:**
- Automatic signing
- Team ID: LMGBU86523
- Remove alpha from icons

### Design Guidelines

- Use glassmorphism for modern UI
- Use Iconsax or similar modern icons
- Use Lottie for animations
- Always use `easy_localization` for text
- Arabic flag: 🇴🇲 (Oman)

### Performance Targets

- 60fps minimum
- 90fps/120fps on supported devices
- Smooth scrolling with `BouncingScrollPhysics`
- Fast app startup (<2 seconds)

---

## 🔗 Key Files Reference

| File | Purpose |
|------|---------|
| `main.dart` | App entry point |
| `injection_container.dart` | DI setup |
| `app_router.dart` | Navigation config |
| `app_theme.dart` | Theme configuration |
| `api_client.dart` | HTTP client |
| `firebase_service.dart` | Firebase integration |
| `notification_service.dart` | Push notifications |
| `performance_utils.dart` | Performance helpers |

---

## 📚 Summary

This architecture provides:

✅ **Scalability** - Easy to add new features  
✅ **Maintainability** - Clear separation of concerns  
✅ **Testability** - Dependency injection enables testing  
✅ **Performance** - Optimized for smooth UX  
✅ **Localization** - Multi-language support  
✅ **Modern UI** - Glassmorphism and Material 3  
✅ **Firebase** - Analytics, Crashlytics, FCM  
✅ **Type Safety** - Null safety enabled  

Use this guide as a blueprint for creating similar Flutter applications with clean architecture and best practices.

---

**Last Updated:** March 2026  
**Flutter Version:** 3.9.2  
**Architecture:** Clean Architecture + Provider

---

# 🚗 SLF Drive - Car Rental Application Specifications

## Project Overview

**App Name:** SLF Drive  
**Type:** Car Rental Platform (Multi-role)  
**Platforms:** Android, iOS, **Web** (Responsive)  
**Architecture:** Same as Absher (Clean Architecture + Provider)  
**Flutter Version:** Latest stable (^3.27.0+)  
**Dependencies:** Latest versions of all packages

---

## 🎨 Brand Colors

### Primary Colors

```dart
// color_constants.dart
const Color primaryColor = Color(0xFF0C2485);      // Deep Blue
const Color secondaryColor = Color(0xFF677EF0);    // Light Blue/Purple

// Primary Gradient
const LinearGradient primaryGradient = LinearGradient(
  colors: [
    Color(0xFF0C2485),  // Deep Blue
    Color(0xFF677EF0),  // Light Blue/Purple
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### Usage Examples

```dart
// Gradient Button
Container(
  decoration: BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(12),
  ),
  child: ElevatedButton(...),
)

// Gradient App Bar
GlassAppBar(
  gradient: primaryGradient,
  title: 'SLF Drive',
)

// Gradient Background
Container(
  decoration: BoxDecoration(
    gradient: primaryGradient.scale(0.1), // Lighter version
  ),
)
```

---

## 👥 User Roles & Features

### Role 1: General User (Customer)

**Core Features:**
1. **Explore Services**
   - Browse available cars
   - View car details (specs, pricing, availability)
   - Filter by category, price, location
   - Search functionality

2. **Book Cars for Rent**
   - Self-drive car rental
   - Select pickup/drop-off dates
   - Choose locations
   - View pricing breakdown
   - Payment integration

3. **Hire Drivers**
   - Browse verified drivers
   - View driver profiles (ratings, experience, reviews)
   - Book driver by hour/day
   - Track driver location

4. **Book Car with Driver**
   - Combined service
   - Select car + driver package
   - Airport transfers
   - City tours
   - Long-distance trips

**Additional Features:**
- Booking history
- Favorites/Wishlist
- Reviews & ratings
- Payment methods management
- Notifications (booking confirmations, reminders)
- Customer support chat

### Role 2: Driver

**Core Features:**
1. **Registration & Verification**
   - Driver registration form
   - Document upload (license, ID, background check)
   - Verification process
   - Approval/rejection notifications

2. **Profile Management**
   - Personal information
   - Profile photo
   - Vehicle details (if applicable)
   - Availability calendar
   - Service areas
   - Pricing settings

3. **Job Management**
   - View booking requests
   - Accept/decline bookings
   - Active bookings dashboard
   - Booking history
   - Earnings tracking

4. **Additional Features**
   - Ratings & reviews from customers
   - Performance analytics
   - Payout management
   - Navigation integration
   - Real-time location sharing during trips

---

## 📱 Responsive Design Strategy

### Layout Breakpoints

```dart
// responsive_utils.dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop;
        } else if (constraints.maxWidth >= Breakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### Responsive Widgets

```dart
// Example: Responsive Car Grid
class CarGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth >= Breakpoints.desktop) {
          crossAxisCount = 4;
          childAspectRatio = 0.8;
        } else if (constraints.maxWidth >= Breakpoints.tablet) {
          crossAxisCount = 3;
          childAspectRatio = 0.75;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 0.7;
        }
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) => CarCard(...),
        );
      },
    );
  }
}
```

### Web-Specific Considerations

**1. Navigation**
```dart
// Use adaptive navigation
- Mobile: Bottom Navigation Bar
- Tablet: Side Navigation Rail
- Desktop: Persistent Drawer + Top Navigation
```

**2. Screen Utilization**
```dart
// Desktop Layout Example
Row(
  children: [
    // Sidebar (filters, menu)
    if (isDesktop) 
      SizedBox(
        width: 280,
        child: FilterSidebar(),
      ),
    
    // Main content
    Expanded(
      child: MainContent(),
    ),
    
    // Right panel (details, cart)
    if (isDesktop)
      SizedBox(
        width: 320,
        child: DetailPanel(),
      ),
  ],
)
```

**3. Input Methods**
```dart
// Support both touch and mouse/keyboard
- Hover effects for desktop
- Keyboard shortcuts
- Right-click context menus
- Drag and drop (where applicable)
```

**4. Performance**
```dart
// Web-specific optimizations
- Image optimization (WebP format)
- Lazy loading
- Code splitting
- Service workers for offline support
```

---

## 📁 Updated Folder Structure for SLF Drive

```
lib/
├── main.dart
├── firebase_options.dart
└── src/
    ├── constants/
    │   ├── color_constants.dart       # Brand colors + gradient
    │   ├── endpoints.dart
    │   ├── breakpoints.dart           # NEW: Responsive breakpoints
    │   └── ...
    │
    ├── core/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_remote_datasource.dart
    │   │   │   ├── car_remote_datasource.dart      # NEW
    │   │   │   ├── booking_remote_datasource.dart  # NEW
    │   │   │   ├── driver_remote_datasource.dart   # NEW
    │   │   │   └── payment_remote_datasource.dart  # NEW
    │   │   └── repositories/
    │   │       ├── car_repository.dart             # NEW
    │   │       ├── booking_repository.dart         # NEW
    │   │       ├── driver_repository.dart          # NEW
    │   │       └── payment_repository.dart         # NEW
    │   │
    │   ├── models/
    │   │   ├── car/                                # NEW
    │   │   │   ├── car_model.dart
    │   │   │   ├── car_category_model.dart
    │   │   │   └── car_availability_model.dart
    │   │   ├── booking/                            # NEW
    │   │   │   ├── booking_model.dart
    │   │   │   ├── booking_request_model.dart
    │   │   │   └── booking_status_model.dart
    │   │   ├── driver/                             # NEW
    │   │   │   ├── driver_model.dart
    │   │   │   ├── driver_verification_model.dart
    │   │   │   └── driver_document_model.dart
    │   │   └── user/
    │   │       └── user_role_enum.dart             # UPDATED: Add roles
    │   │
    │   └── ...
    │
    └── presentation/
        ├── providers/
        │   ├── auth_provider.dart
        │   ├── car_provider.dart                   # NEW
        │   ├── booking_provider.dart               # NEW
        │   ├── driver_provider.dart                # NEW
        │   └── role_provider.dart                  # NEW: Manage user role
        │
        ├── screens/
        │   ├── customer/                           # NEW: Customer screens
        │   │   ├── home/
        │   │   ├── car_listing/
        │   │   ├── car_detail/
        │   │   ├── booking/
        │   │   ├── driver_listing/
        │   │   ├── driver_detail/
        │   │   └── my_bookings/
        │   │
        │   ├── driver/                             # NEW: Driver screens
        │   │   ├── dashboard/
        │   │   ├── registration/
        │   │   ├── verification/
        │   │   ├── profile/
        │   │   ├── bookings/
        │   │   └── earnings/
        │   │
        │   ├── common/                             # Shared screens
        │   │   ├── auth/
        │   │   ├── splash/
        │   │   ├── onboarding/
        │   │   └── role_selection/
        │   │
        │   └── web/                                # NEW: Web-specific screens
        │       ├── web_home/
        │       └── web_dashboard/
        │
        ├── widgets/
        │   ├── responsive/                         # NEW: Responsive widgets
        │   │   ├── responsive_layout.dart
        │   │   ├── responsive_grid.dart
        │   │   ├── adaptive_navigation.dart
        │   │   └── breakpoint_builder.dart
        │   ├── gradient_button.dart                # NEW
        │   ├── gradient_app_bar.dart               # NEW
        │   └── ...
        │
        └── utils/
            ├── responsive_utils.dart               # NEW
            └── platform_utils.dart                 # NEW: Detect platform
```

---

## 📦 Updated Dependencies (Latest Versions)

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management & DI
  provider: ^6.1.5                    # Latest stable
  get_it: ^8.2.0                      # Latest stable
  
  # Navigation
  go_router: ^14.6.2                  # Latest with web support
  
  # Network
  dio: ^5.9.0                         # Latest
  connectivity_plus: ^7.0.0           # Latest
  
  # Storage
  flutter_secure_storage: ^9.2.4     # Latest
  shared_preferences: ^2.3.5          # For web compatibility
  hive_flutter: ^1.1.0                # Fast local storage
  
  # UI & Responsive
  flutter_screenutil: ^5.9.3          # Responsive sizing
  responsive_framework: ^1.5.1        # NEW: Web responsive
  flutter_adaptive_scaffold: ^0.2.4   # NEW: Adaptive layouts
  
  # UI Components
  flutter_svg: ^2.2.3
  cached_network_image: ^3.4.1
  lottie: ^3.3.2
  iconsax_flutter: ^1.0.1
  shimmer: ^3.0.0                     # Loading effect
  
  # Maps & Location
  google_maps_flutter: ^2.9.0         # Maps integration
  google_maps_flutter_web: ^0.5.10    # NEW: Web maps
  geolocator: ^13.0.2                 # Location services
  geocoding: ^3.0.0                   # Address lookup
  
  # Date & Time
  intl: ^0.20.2
  easy_localization: ^3.0.8
  syncfusion_flutter_datepicker: ^28.2.7  # Date range picker
  
  # Payment
  flutter_stripe: ^11.2.0             # Stripe integration
  # razorpay_flutter: ^1.3.7          # Alternative payment
  
  # Firebase
  firebase_core: ^3.13.0
  firebase_auth: ^5.3.6               # Optional: Can use REST API auth instead
  firebase_analytics: ^11.4.6
  firebase_crashlytics: ^4.3.6
  firebase_messaging: ^15.2.5
  firebase_storage: ^12.3.8           # For document uploads (or use REST API)
  
  # File Handling
  file_picker: ^8.0.0
  image_picker: ^1.2.0
  image_cropper: ^8.0.2               # Crop profile images
  
  # PDF & Documents
  pdf: ^3.11.1                        # Generate invoices
  printing: ^5.13.4                   # Print/share PDFs
  
  # Utilities
  url_launcher: ^6.3.1
  share_plus: ^10.1.4
  package_info_plus: ^8.3.1
  permission_handler: ^12.0.1
  
  # Rating & Reviews
  flutter_rating_bar: ^4.0.1
  
  # Chat (Optional)
  # stream_chat_flutter: ^8.0.0       # If implementing chat
  
  # Analytics
  clarity_flutter: ^1.7.1             # Microsoft Clarity

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.14.4
  flutter_native_splash: ^2.4.7
  build_runner: ^2.4.13               # For code generation
```

---

## 🎯 Key Features Implementation

### 1. Role-Based Access Control

```dart
// role_provider.dart
enum UserRole { customer, driver }

class RoleProvider extends ChangeNotifier {
  UserRole? _currentRole;
  
  UserRole? get currentRole => _currentRole;
  bool get isCustomer => _currentRole == UserRole.customer;
  bool get isDriver => _currentRole == UserRole.driver;
  
  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }
}

// In app_router.dart
redirect: (context, state) {
  final role = getIt<RoleProvider>().currentRole;
  
  if (state.uri.path.startsWith('/customer') && !role.isCustomer) {
    return '/role-selection';
  }
  if (state.uri.path.startsWith('/driver') && !role.isDriver) {
    return '/role-selection';
  }
  return null;
}
```

### 2. Booking System

```dart
// booking_model.dart
class BookingModel {
  final String id;
  final String carId;
  final String userId;
  final String? driverId;
  final BookingType type; // selfDrive, hireDriver, carWithDriver
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final String pickupLocation;
  final String dropoffLocation;
  final double totalPrice;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
}

enum BookingType { selfDrive, hireDriver, carWithDriver }
enum BookingStatus { pending, confirmed, active, completed, cancelled }
```

### 3. Driver Verification Flow

```dart
// driver_verification_model.dart
class DriverVerificationModel {
  final String driverId;
  final VerificationStatus status;
  final List<DocumentModel> documents;
  final String? rejectionReason;
  final DateTime? verifiedAt;
}

enum VerificationStatus { 
  pending, 
  underReview, 
  approved, 
  rejected 
}

class DocumentModel {
  final String type; // license, id, backgroundCheck
  final String url;
  final bool isVerified;
}
```

### 4. Real-time Location Tracking

```dart
// location_service.dart
class LocationService {
  final ApiClient _apiClient;
  
  LocationService(this._apiClient);
  
  Stream<Position> trackDriverLocation(String driverId) {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
  
  Future<void> updateDriverLocation(String driverId, Position position) async {
    await _apiClient.put(
      '/drivers/$driverId/location',
      data: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // Get driver's current location from API
  Future<Position?> getDriverLocation(String driverId) async {
    final response = await _apiClient.get('/drivers/$driverId/location');
    if (response.data != null) {
      return Position(
        latitude: response.data['latitude'],
        longitude: response.data['longitude'],
        timestamp: DateTime.parse(response.data['timestamp']),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    return null;
  }
}
```

---

## 🔌 REST API Integration

### API Client Configuration

```dart
// api_client.dart
class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  
  ApiClient(this._storage) : _dio = Dio() {
    _dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add interceptors
    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT, DELETE methods...
}
```

### Auth Interceptor

```dart
// auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  
  AuthInterceptor(this._storage);
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the request
        final options = err.requestOptions;
        final response = await Dio().fetch(options);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }
  
  Future<bool> _refreshToken() async {
    // Implement token refresh logic
    return false;
  }
}
```

### Repository Implementation with REST API

```dart
// car_repository.dart
abstract class CarRepository {
  Future<ApiResponse<List<CarModel>>> getCars({
    String? category,
    double? minPrice,
    double? maxPrice,
  });
  Future<ApiResponse<CarModel>> getCarById(String id);
}

class CarRepositoryImpl implements CarRepository {
  final ApiClient _apiClient;
  
  CarRepositoryImpl(this._apiClient);
  
  @override
  Future<ApiResponse<List<CarModel>>> getCars({
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{};
    if (category != null) queryParams['category'] = category;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    
    final response = await _apiClient.get('/cars', queryParameters: queryParams);
    
    return ApiResponse(
      success: response.success,
      data: (response.data as List)
          .map((json) => CarModel.fromJson(json))
          .toList(),
      message: response.message,
    );
  }
  
  @override
  Future<ApiResponse<CarModel>> getCarById(String id) async {
    final response = await _apiClient.get('/cars/$id');
    return ApiResponse(
      success: response.success,
      data: CarModel.fromJson(response.data),
      message: response.message,
    );
  }
}
```

### WebSocket for Real-time Updates (Optional)

```dart
// websocket_service.dart
class WebSocketService {
  IOWebSocketChannel? _channel;
  final String baseUrl;
  
  WebSocketService(this.baseUrl);
  
  void connect(String token) {
    _channel = IOWebSocketChannel.connect(
      '$baseUrl/ws?token=$token',
    );
    
    _channel!.stream.listen(
      (message) {
        _handleMessage(jsonDecode(message));
      },
      onError: (error) => print('WebSocket error: $error'),
      onDone: () => _reconnect(),
    );
  }
  
  void _handleMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'booking_update':
        // Handle booking status update
        break;
      case 'driver_location':
        // Handle driver location update
        break;
      case 'notification':
        // Handle new notification
        break;
    }
  }
  
  void send(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }
  
  void disconnect() {
    _channel?.sink.close();
  }
}
```

### Environment Configuration

```env
# .env
API_BASE_URL=https://api.slfdrive.com/v1
WS_BASE_URL=wss://api.slfdrive.com/v1
STRIPE_PUBLISHABLE_KEY=pk_test_...
GOOGLE_MAPS_API_KEY=AIza...
```

---

## 🌐 Web Deployment Configuration

### 1. Web-Specific Setup

```yaml
# pubspec.yaml - Web assets
flutter:
  assets:
    - assets/web/
    - assets/web/icons/
    - assets/web/images/
```

### 2. Web Index.html Configuration

```html
<!-- web/index.html -->
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="SLF Drive - Car Rental & Driver Services">
  
  <!-- PWA Support -->
  <link rel="manifest" href="manifest.json">
  <meta name="theme-color" content="#0C2485">
  
  <!-- Google Maps -->
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY"></script>
</head>
```

### 3. Responsive Web Layout Example

```dart
// web_home_screen.dart
class WebHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: MobileHomeScreen(),
      tablet: TabletHomeScreen(),
      desktop: Scaffold(
        body: Row(
          children: [
            // Sidebar Navigation
            NavigationRail(
              selectedIndex: 0,
              destinations: [...],
            ),
            
            // Main Content
            Expanded(
              flex: 2,
              child: CarListingSection(),
            ),
            
            // Right Panel (Filters/Details)
            SizedBox(
              width: 320,
              child: FilterPanel(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎨 Theme with Gradient Support

```dart
// app_theme.dart
class AppTheme {
  static ThemeData lightTheme(String fontFamily) {
    return ThemeData(
      useMaterial3: true,
      primaryColor: const Color(0xFF0C2485),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF0C2485),
        secondary: const Color(0xFF677EF0),
      ),
      
      // Gradient Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // ... rest of theme
    );
  }
}

// gradient_button.dart
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(text),
      ),
    );
  }
}
```

---

## 📋 Implementation Checklist

### Phase 1: Foundation
- [ ] Setup project with latest Flutter version
- [ ] Configure responsive framework
- [ ] Implement folder structure
- [ ] Setup Firebase
- [ ] Configure web deployment
- [ ] Implement theme with gradient colors
- [ ] Setup dependency injection
- [ ] Create base models

### Phase 2: Authentication & Roles
- [ ] Implement auth flow
- [ ] Create role selection screen
- [ ] Setup role-based routing
- [ ] Implement customer registration
- [ ] Implement driver registration

### Phase 3: Customer Features
- [ ] Car listing screen (responsive)
- [ ] Car detail screen
- [ ] Booking flow
- [ ] Driver listing
- [ ] Payment integration
- [ ] Booking history

### Phase 4: Driver Features
- [ ] Driver dashboard
- [ ] Document upload & verification
- [ ] Profile management
- [ ] Booking requests
- [ ] Earnings tracking
- [ ] Location tracking

### Phase 5: Web Optimization
- [ ] Responsive layouts for all screens
- [ ] Desktop navigation
- [ ] SEO optimization
- [ ] PWA configuration
- [ ] Performance optimization
- [ ] Cross-browser testing

### Phase 6: Testing & Deployment
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Web hosting setup
- [ ] App store deployment
- [ ] Analytics integration

---

## 🚀 Quick Start Commands

```bash
# Create new Flutter project
flutter create slf_drive

# Add dependencies
flutter pub add provider get_it go_router dio flutter_screenutil responsive_framework

# Run on web
flutter run -d chrome

# Build for web
flutter build web --release

# Build for mobile
flutter build apk --release
flutter build ios --release
```

---

## 📊 REST API Endpoints

### Authentication
```
POST   /api/auth/register          # Register new user
POST   /api/auth/login             # Login with phone/email
POST   /api/auth/verify-otp        # Verify OTP
POST   /api/auth/refresh-token     # Refresh access token
POST   /api/auth/logout            # Logout user
```

### Users
```
GET    /api/users/me               # Get current user profile
PUT    /api/users/me               # Update user profile
PUT    /api/users/me/role          # Update user role (customer/driver)
DELETE /api/users/me               # Delete account
```

### Cars
```
GET    /api/cars                   # List all cars (with filters)
GET    /api/cars/:id               # Get car details
POST   /api/cars                   # Create car (admin)
PUT    /api/cars/:id               # Update car (admin)
DELETE /api/cars/:id               # Delete car (admin)
GET    /api/cars/search            # Search cars (query params)
GET    /api/cars/categories        # Get car categories
```

### Drivers
```
POST   /api/drivers/register       # Driver registration
GET    /api/drivers                # List verified drivers
GET    /api/drivers/:id            # Get driver details
PUT    /api/drivers/:id            # Update driver profile
POST   /api/drivers/:id/documents  # Upload verification documents
GET    /api/drivers/:id/documents  # Get driver documents
PUT    /api/drivers/:id/location   # Update driver location
GET    /api/drivers/:id/location   # Get driver location
GET    /api/drivers/:id/availability # Get driver availability
PUT    /api/drivers/:id/availability # Update availability
GET    /api/drivers/:id/earnings   # Get driver earnings
```

### Bookings
```
POST   /api/bookings               # Create new booking
GET    /api/bookings               # List user's bookings
GET    /api/bookings/:id           # Get booking details
PUT    /api/bookings/:id           # Update booking
DELETE /api/bookings/:id           # Cancel booking
POST   /api/bookings/:id/confirm   # Confirm booking (driver)
POST   /api/bookings/:id/complete  # Complete booking
GET    /api/bookings/:id/invoice   # Get booking invoice
```

### Reviews
```
POST   /api/reviews                # Create review
GET    /api/reviews/car/:carId     # Get car reviews
GET    /api/reviews/driver/:driverId # Get driver reviews
PUT    /api/reviews/:id            # Update review
DELETE /api/reviews/:id            # Delete review
```

### Payments
```
POST   /api/payments/intent        # Create payment intent
POST   /api/payments/confirm       # Confirm payment
GET    /api/payments/:id           # Get payment details
GET    /api/payments/methods       # Get saved payment methods
POST   /api/payments/methods       # Add payment method
DELETE /api/payments/methods/:id   # Remove payment method
```

### Admin (Driver Verification)
```
GET    /api/admin/drivers/pending  # Get pending driver verifications
PUT    /api/admin/drivers/:id/verify # Approve driver
PUT    /api/admin/drivers/:id/reject # Reject driver
```

### Notifications
```
GET    /api/notifications          # Get user notifications
PUT    /api/notifications/:id/read # Mark as read
DELETE /api/notifications/:id      # Delete notification
POST   /api/notifications/token    # Register FCM token
```

### Data Models (JSON Response Examples)

**User Model:**
```json
{
  "id": "user_123",
  "role": "customer",
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "+96812345678",
  "profileImage": "https://...",
  "createdAt": "2026-04-01T12:00:00Z",
  "updatedAt": "2026-04-01T12:00:00Z"
}
```

**Car Model:**
```json
{
  "id": "car_123",
  "name": "Toyota Camry 2024",
  "brand": "Toyota",
  "model": "Camry",
  "year": 2024,
  "category": "sedan",
  "pricePerDay": 45.00,
  "images": ["https://...", "https://..."],
  "features": ["AC", "GPS", "Bluetooth"],
  "availability": true,
  "location": {
    "latitude": 23.5880,
    "longitude": 58.3829,
    "address": "Muscat, Oman"
  },
  "specs": {
    "transmission": "automatic",
    "fuelType": "petrol",
    "seats": 5
  }
}
```

**Driver Model:**
```json
{
  "id": "driver_123",
  "userId": "user_456",
  "verificationStatus": "approved",
  "rating": 4.8,
  "totalTrips": 150,
  "availability": true,
  "pricePerHour": 8.00,
  "location": {
    "latitude": 23.5880,
    "longitude": 58.3829
  },
  "documents": [
    {
      "type": "license",
      "url": "https://...",
      "verified": true
    }
  ],
  "vehicle": {
    "make": "Toyota",
    "model": "Corolla",
    "year": 2023,
    "plateNumber": "ABC-1234"
  }
}
```

**Booking Model:**
```json
{
  "id": "booking_123",
  "userId": "user_123",
  "carId": "car_456",
  "driverId": "driver_789",
  "type": "carWithDriver",
  "status": "confirmed",
  "paymentStatus": "paid",
  "pickupDate": "2026-04-05T10:00:00Z",
  "dropoffDate": "2026-04-07T18:00:00Z",
  "pickupLocation": {
    "latitude": 23.5880,
    "longitude": 58.3829,
    "address": "Muscat Airport"
  },
  "dropoffLocation": {
    "latitude": 23.6100,
    "longitude": 58.5400,
    "address": "Muscat Hotel"
  },
  "totalPrice": 180.00,
  "createdAt": "2026-04-01T12:00:00Z"
}
```

---

This comprehensive guide provides everything needed to build SLF Drive with the same architecture as Absher, but optimized for the latest Flutter version, web support, REST API backend, and the dual-role car rental platform requirements.
