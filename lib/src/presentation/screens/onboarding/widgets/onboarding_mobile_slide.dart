import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingMobileSlide extends StatelessWidget {
  final int pageKey;
  final String title;
  final String description;

  const OnboardingMobileSlide({
    super.key,
    required this.pageKey,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey(pageKey),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.r),
            child: Text(
              title,
              style: TextStyle(fontSize: 40.r, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 48.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 20.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.r, color: Colors.white, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
