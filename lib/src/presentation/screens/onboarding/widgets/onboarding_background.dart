import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  final String image;
  final int pageKey;

  const OnboardingBackground({super.key, required this.image, required this.pageKey});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            image,
            key: ValueKey(pageKey),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.4)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
