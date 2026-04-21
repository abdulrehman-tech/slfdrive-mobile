import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_fade_through_transition.dart';
import '../providers/role_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/language/language_selection_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/common/auth/pre_login_screen.dart';
import '../screens/common/auth/login/phone_login_screen.dart';
import '../screens/common/auth/otp/otp_verification_screen.dart';
import '../screens/common/auth/profile_completion_screen.dart';
import '../screens/common/coming_soon_screen.dart';
import '../screens/customer/home/customer_home_screen.dart';
import '../screens/customer/car_listing/car_listing_screen.dart';
import '../screens/customer/car_detail/car_detail_screen.dart';
import '../screens/customer/driver_listing/driver_listing_screen.dart';
import '../screens/customer/driver_detail/driver_detail_screen.dart';
import '../screens/customer/search/search_screen.dart';
import '../screens/customer/brands/brands_screen.dart';
import '../screens/customer/notifications/notifications_screen.dart';
import '../screens/customer/booking/booking_flow_screen.dart';
import '../screens/customer/booking/location_picker_screen.dart';
import '../screens/customer/booking/models/booking_data.dart';
import '../screens/customer/booking_detail/booking_detail_screen.dart';
import '../screens/customer/bookings/bookings_screen.dart';
import '../screens/customer/favorites/favorites_screen.dart';
import '../screens/customer/profile/profile_screen.dart';
import '../screens/driver/home/driver_home_screen.dart';
import '../screens/driver/earnings/driver_earnings_screen.dart';
import '../screens/driver/trips/driver_trips_screen.dart';
import '../screens/driver/profile/driver_profile_screen.dart';

/// Professional page transition with shared axis pattern.
/// Uses Material 3 motion principles with elegant easing curves.
class AppPageTransition extends CustomTransitionPage {
  AppPageTransition({required super.child, super.name, super.arguments, super.restorationId})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const enterCurve = Curves.easeOutCubic;
          const exitCurve = Curves.easeInCubic;

          final primaryAnimation = CurvedAnimation(parent: animation, curve: enterCurve, reverseCurve: exitCurve);

          const slideDistance = 0.03;

          final enterSlide = Tween<Offset>(
            begin: const Offset(slideDistance, 0),
            end: Offset.zero,
          ).animate(primaryAnimation);

          final enterFade = Tween<double>(begin: 0.0, end: 1.0).animate(primaryAnimation);
          final enterScale = Tween<double>(begin: 0.95, end: 1.0).animate(primaryAnimation);

          return SlideTransition(
            position: enterSlide,
            child: FadeTransition(
              opacity: enterFade,
              child: ScaleTransition(scale: enterScale, child: child),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 450),
      );
}

/// Modal-style transition for detail screens that should feel like overlays.
class AppModalTransition extends CustomTransitionPage {
  AppModalTransition({required super.child, super.name, super.arguments, super.restorationId})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const enterCurve = Curves.easeOutCubic;
          const exitCurve = Curves.easeInCubic;

          final primaryAnimation = CurvedAnimation(parent: animation, curve: enterCurve, reverseCurve: exitCurve);

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(primaryAnimation);

          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(primaryAnimation);
          final scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(primaryAnimation);

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration: const Duration(milliseconds: 500),
      );
}

/// Pre-auth routes — anyone may visit these regardless of role.
const _preAuthRoutes = {
  '/',
  '/language-selection',
  '/onboarding',
  '/auth',
  '/auth/phone',
  '/auth/otp',
  '/auth/profile-completion',
};

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final role = context.read<RoleProvider>().role;
      final loc = state.matchedLocation;

      if (_preAuthRoutes.contains(loc)) return null;

      // Unauthenticated → send to auth.
      if (role == null) return '/auth';

      // Role fencing: customers can't enter /driver/*, drivers can't enter
      // customer-scoped routes. Match '/driver/' (with trailing slash) so
      // '/drivers' and '/drivers/:id' (customer-facing driver browse) still
      // resolve as customer routes.
      final isDriverShellRoute = loc == '/driver' || loc.startsWith('/driver/');
      if (isDriverShellRoute && role != UserRole.driver) return '/home';
      if (!isDriverShellRoute && role == UserRole.driver) return '/driver/home';

      return null;
    },
    errorBuilder: (context, state) => const ComingSoonScreen(titleKey: 'error_route_not_found'),
    routes: [
      // ── Pre-auth ─────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => AppFadeThroughTransition(child: const SplashScreen(), name: state.name),
      ),
      GoRoute(
        path: '/language-selection',
        name: 'language-selection',
        pageBuilder: (context, state) =>
            AppFadeThroughTransition(child: const LanguageSelectionScreen(), name: state.name),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => AppFadeThroughTransition(child: const OnboardingScreen(), name: state.name),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        pageBuilder: (context, state) => AppPageTransition(child: const PreLoginScreen(), name: state.name),
      ),
      GoRoute(
        path: '/auth/phone',
        name: 'phone-login',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isDriver = extra?['isDriver'] as bool? ?? false;
          return AppPageTransition(
            child: PhoneLoginScreen(isDriver: isDriver),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'otp-verification',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '';
          final isDriver = extra?['isDriver'] as bool? ?? false;
          final deliveryMethod = extra?['deliveryMethod'] as String? ?? 'sms';
          return AppPageTransition(
            child: OtpVerificationScreen(phoneNumber: phone, isDriver: isDriver, deliveryMethod: deliveryMethod),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/auth/profile-completion',
        name: 'profile-completion',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '';
          final isDriver = extra?['isDriver'] as bool? ?? false;
          return AppPageTransition(
            child: ProfileCompletionScreen(phoneNumber: phone, isDriver: isDriver),
            name: state.name,
          );
        },
      ),

      // ── Customer shell tabs ─────────────────────────────────
      // Each tab renders CustomerHomeScreen with a different body so the
      // drawer + bottom-nav + desktop side-nav chrome persists visually.
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => AppPageTransition(child: const CustomerHomeScreen(), name: state.name),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        pageBuilder: (context, state) => AppPageTransition(
          child: const CustomerHomeScreen(tabBody: FavoritesScreen()),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        pageBuilder: (context, state) => AppPageTransition(
          child: const CustomerHomeScreen(tabBody: BookingsScreen()),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => AppPageTransition(
          child: const CustomerHomeScreen(tabBody: ProfileScreen()),
          name: state.name,
        ),
      ),

      // ── Customer detail / flow routes (push on top of shell) ─
      GoRoute(
        path: '/cars',
        name: 'car-listing',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final brand = extra?['brand'] as String?;
          return AppPageTransition(
            child: CarListingScreen(initialBrand: brand),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/cars/:id',
        name: 'car-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AppModalTransition(
            child: CarDetailScreen(carId: id),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/drivers',
        name: 'driver-listing',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final filter = extra?['filter'] as String?;
          return AppPageTransition(
            child: DriverListingScreen(initialFilter: filter),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/drivers/:id',
        name: 'driver-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AppModalTransition(
            child: DriverDetailScreen(driverId: id),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) => AppModalTransition(child: const SearchScreen(), name: state.name),
      ),
      GoRoute(
        path: '/brands',
        name: 'brands',
        pageBuilder: (context, state) => AppPageTransition(child: const BrandsScreen(), name: state.name),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => AppModalTransition(child: const NotificationsScreen(), name: state.name),
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final service = extra?['service'] as BookingServiceType?;
          final car = extra?['car'] as BookingCar?;
          final driver = extra?['driver'] as BookingDriver?;
          return AppModalTransition(
            child: BookingFlowScreen(initialServiceType: service, initialCar: car, initialDriver: driver),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/booking/location',
        name: 'booking-location-picker',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final initial = extra?['initial'] as BookingLocation?;
          final forDelivery = extra?['forDelivery'] as bool? ?? false;
          return AppModalTransition(
            child: LocationPickerScreen(initial: initial, forDelivery: forDelivery),
            name: state.name,
          );
        },
      ),
      GoRoute(
        path: '/bookings/:id',
        name: 'booking-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AppModalTransition(
            child: BookingDetailScreen(bookingId: id),
            name: state.name,
          );
        },
      ),

      // ── ComingSoon placeholders (Phase 2 destinations) ──────
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'profile_edit_title'), name: state.name),
      ),
      GoRoute(
        path: '/profile/addresses',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'profile_addresses_title'), name: state.name),
      ),
      GoRoute(
        path: '/profile/payments',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'profile_payments_title'), name: state.name),
      ),
      GoRoute(
        path: '/profile/kyc',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'profile_kyc_title'), name: state.name),
      ),
      GoRoute(
        path: '/my-vehicles',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'drawer_my_vehicles_title'), name: state.name),
      ),
      GoRoute(
        path: '/help',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'help_center_title'), name: state.name),
      ),
      GoRoute(
        path: '/legal/terms',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'legal_terms_title'), name: state.name),
      ),
      GoRoute(
        path: '/legal/privacy',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'legal_privacy_title'), name: state.name),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) =>
            AppPageTransition(child: const ComingSoonScreen(titleKey: 'about_title'), name: state.name),
      ),

      // ── Driver shell tabs ───────────────────────────────────
      GoRoute(
        path: '/driver/home',
        name: 'driver-home',
        pageBuilder: (context, state) => AppPageTransition(child: const DriverHomeScreen(), name: state.name),
      ),
      GoRoute(
        path: '/driver/earnings',
        name: 'driver-earnings',
        pageBuilder: (context, state) => AppPageTransition(
          child: const DriverHomeScreen(tabBody: DriverEarningsScreen()),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/driver/trips',
        name: 'driver-trips',
        pageBuilder: (context, state) => AppPageTransition(
          child: const DriverHomeScreen(tabBody: DriverTripsScreen()),
          name: state.name,
        ),
      ),
      GoRoute(
        path: '/driver/profile',
        name: 'driver-profile',
        pageBuilder: (context, state) => AppPageTransition(
          child: const DriverHomeScreen(tabBody: DriverProfileScreen()),
          name: state.name,
        ),
      ),
    ],
  );
}
