import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../constants/breakpoints.dart';
import 'provider/onboarding_provider.dart';
import 'widgets/onboarding_desktop_layout.dart';
import 'widgets/onboarding_mobile_layout.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  void _onNext(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    if (!provider.goNext()) {
      _onGetStarted(context);
    }
  }

  void _onSkip(BuildContext context) {
    _onGetStarted(context);
  }

  void _onGetStarted(BuildContext context) {
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

          if (isDesktop) {
            return OnboardingDesktopLayout(
              onNext: () => _onNext(context),
              onSkip: () => _onSkip(context),
            );
          }

          return OnboardingMobileLayout(
            onNext: () => _onNext(context),
            onSkip: () => _onSkip(context),
          );
        },
      ),
    );
  }
}
