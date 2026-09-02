import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../core/models/notification/push_payload.dart';
import '../providers/role_provider.dart';
import 'app_router.dart';

/// Maps a push payload to an in-app route, and performs the navigation.
///
/// Lives in the presentation layer because routing is role-dependent, which
/// keeps `PushMessagingService` role-agnostic.
///
/// Two constraints shape everything here:
///
/// 1. **`state.extra` is unusable.** A tap on a terminated app is a cold start,
///    and `extra` does not survive one. Every push route is therefore built from
///    path parameters only. `/bookings/:id` already tolerates a null
///    `BookingDetailSeed` and fetches, so that works as-is.
/// 2. **The router's role fence.** `redirect` bounces a driver off any route
///    outside `/driver/*` to `/driver/home` (except the shared-authed set). So a
///    driver is never routed to a customer-scoped screen; driver pushes resolve
///    to driver-shell routes instead. `/notifications` is exempt because it is
///    role-neutral — see `_sharedAuthedRoutes` in app_router.dart.
String? resolvePushRoute(PushPayload p, UserRole? role) {
  // A guest has no session, so every deep target is behind auth and no token was
  // ever registered. Leave the item in the inbox; don't route.
  if (role == null) return null;

  // Suppress cross-role sends outright.
  final target = p.targetRole;
  if (target != null && target != role.name) return null;

  final isDriver = role == UserRole.driver;

  // An explicit server route wins, but only after the role fence — a malformed
  // one must not be able to bounce a driver out to /auth.
  final explicit = p.explicitRoute;
  if (explicit != null) {
    if (isDriver && !_isDriverSafeRoute(explicit)) return '/driver/home';
    return explicit;
  }

  switch (p.type) {
    case 'booking':
    case 'booking_status':
    case 'payment':
      if (isDriver) return '/driver/trips';
      final id = p.bookingId;
      return id == null ? '/bookings' : '/bookings/$id';
    case 'earnings':
      return isDriver ? '/driver/earnings' : '/notifications';
    case 'promotion':
    case 'system':
    case 'account':
    default:
      return '/notifications';
  }
}

/// Routes a driver may reach: the driver shell plus the role-neutral routes the
/// router's `_sharedAuthedRoutes` exempts from fencing.
bool _isDriverSafeRoute(String route) =>
    route == '/driver' ||
    route.startsWith('/driver/') ||
    route == '/notifications' ||
    route.startsWith('/notifications/') ||
    route == '/profile' ||
    route.startsWith('/profile/') ||
    route == '/help' ||
    route.startsWith('/help/') ||
    route == '/legal' ||
    route.startsWith('/legal/');

/// [resolvePushRoute] against the currently signed-in role, read off the live
/// widget tree. Returns null when there is no context yet (very early startup).
String? resolvePushRouteForCurrentRole(PushPayload p) {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return null;
  return resolvePushRoute(p, ctx.read<RoleProvider>().role);
}

/// Navigates for a notification tap. Safe to call from anywhere.
///
/// Returns false when the tap could not be handled yet, so the caller can keep
/// the payload queued: either the widget tree isn't up, or the router is still
/// on the splash route, which owns the post-boot landing decision and would
/// stomp any navigation issued before it runs (see `SplashScreen._navigateNext`).
bool handlePushTap(PushPayload p) {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return false;

  final router = AppRouter.router;
  if (router.routerDelegate.currentConfiguration.uri.path == '/') return false;

  final route = resolvePushRoute(p, ctx.read<RoleProvider>().role);
  if (route == null) return true; // handled: deliberately not actionable

  try {
    // push(), not go(): the shell stays underneath so Back returns to it.
    router.push(route);
  } catch (e) {
    debugPrint('[Push] Navigation to $route failed: $e');
  }
  return true;
}
