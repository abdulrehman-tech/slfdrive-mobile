import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../constants/image_constants.dart';
import '../../../constants/icon_constants.dart';
import '../../../constants/color_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  List<OnboardingPage> get _pages => [
    OnboardingPage(
      image: ImageConstants.onboarding1,
      title: 'onboarding_1_title'.tr(),
      description: 'onboarding_1_desc'.tr(),
    ),
    OnboardingPage(
      image: ImageConstants.onboarding2,
      title: 'onboarding_2_title'.tr(),
      description: 'onboarding_2_desc'.tr(),
    ),
    OnboardingPage(
      image: ImageConstants.onboarding3,
      title: 'onboarding_3_title'.tr(),
      description: 'onboarding_3_desc'.tr(),
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      _onGetStarted();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _onSkip() {
    _onGetStarted();
  }

  void _onGetStarted() {
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with animated transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              _pages[_currentPage].image,
              key: ValueKey(_currentPage),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Dark Overlay
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

          // Content
          SafeArea(
            child: Column(
              children: [
                // Logo at top
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 20.r),
                  child: SvgPicture.asset(IconConstants.logoWhite, width: 200.r, height: 200.r),
                ),

                const Spacer(),

                // Animated Title and Description
                AnimatedSwitcher(
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
                    key: ValueKey(_currentPage),
                    children: [
                      // Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.r),
                        child: Text(
                          _pages[_currentPage].title,
                          style: TextStyle(
                            fontSize: 40.r,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 48.r),

                      // Description Card
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
                            _pages[_currentPage].description,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.r, color: Colors.white, height: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.r),

                // Fixed Bottom Area
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32.r, vertical: 24.r),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4.r),
                            width: index == _currentPage ? 32.r : 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: index == _currentPage ? Colors.white : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.r),

                      // Buttons Row
                      Row(
                        children: [
                          // Back Button (only show on pages 2 and 3)
                          if (_currentPage > 0)
                            Container(
                              width: 56.r,
                              height: 56.r,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _onBack,
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.r),
                                ),
                              ),
                            ),

                          if (_currentPage > 0) SizedBox(width: 12.r),

                          // Next/Get Started Button
                          Expanded(
                            child: Container(
                              height: 56.r,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _onNext,
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isLastPage ? 'get_started'.tr() : 'next'.tr(),
                                          style: TextStyle(
                                            fontSize: 16.r,
                                            fontWeight: FontWeight.w600,
                                            color: secondaryColor,
                                          ),
                                        ),
                                        SizedBox(width: 8.r),
                                        Icon(Icons.arrow_forward_ios, color: secondaryColor, size: 16.r),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (!isLastPage) SizedBox(width: 12.r),

                          // Skip Button (only show on pages 1 and 2)
                          if (!isLastPage)
                            Container(
                              width: 80.r,
                              height: 56.r,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _onSkip,
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Center(
                                    child: Text(
                                      'skip'.tr(),
                                      style: TextStyle(
                                        fontSize: 14.r,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  OnboardingPage({required this.image, required this.title, required this.description});
}
