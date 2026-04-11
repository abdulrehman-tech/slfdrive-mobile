import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fade-through transition for splash and onboarding screens.
/// Pure cross-fade with subtle scale for a smooth, elegant transition.
class AppFadeThroughTransition extends CustomTransitionPage {
  AppFadeThroughTransition({required super.child, super.name, super.arguments, super.restorationId})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOutCubic;

          final primaryAnimation = CurvedAnimation(parent: animation, curve: curve);

          // Entering screen fades in with subtle scale
          final enterFade = Tween<double>(begin: 0.0, end: 1.0).animate(primaryAnimation);

          final enterScale = Tween<double>(begin: 0.97, end: 1.0).animate(primaryAnimation);

          // Single transition - no Stack to avoid GlobalKey conflicts
          return FadeTransition(
            opacity: enterFade,
            child: ScaleTransition(scale: enterScale, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 500),
      );
}
