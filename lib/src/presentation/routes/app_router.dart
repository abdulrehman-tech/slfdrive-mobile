import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/language/language_selection_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/common/auth/pre_login_screen.dart';
import '../screens/common/auth/login/phone_login_screen.dart';
import '../screens/common/auth/otp/otp_verification_screen.dart';
import '../screens/common/auth/profile_completion_screen.dart';
import '../screens/customer/home/customer_home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/language-selection',
        name: 'language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/auth', name: 'auth', builder: (context, state) => const PreLoginScreen()),
      GoRoute(
        path: '/auth/phone',
        name: 'phone-login',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isDriver = extra?['isDriver'] as bool? ?? false;
          return PhoneLoginScreen(isDriver: isDriver);
        },
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '';
          final isDriver = extra?['isDriver'] as bool? ?? false;
          return OtpVerificationScreen(phoneNumber: phone, isDriver: isDriver);
        },
      ),
      GoRoute(
        path: '/auth/profile-completion',
        name: 'profile-completion',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '';
          final isDriver = extra?['isDriver'] as bool? ?? false;
          return ProfileCompletionScreen(phoneNumber: phone, isDriver: isDriver);
        },
      ),
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const CustomerHomeScreen()),
      GoRoute(
        path: '/driver/home',
        name: 'driver-home',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Driver Home Screen - To be implemented'))),
      ),
    ],
  );
}
