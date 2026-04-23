import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../constants/icon_constants.dart';
import '../provider/onboarding_provider.dart';
import 'onboarding_back_button.dart';
import 'onboarding_background.dart';
import 'onboarding_mobile_slide.dart';
import 'onboarding_next_button.dart';
import 'onboarding_page_indicator.dart';
import 'onboarding_skip_button.dart';

class OnboardingMobileLayout extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingMobileLayout({super.key, required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final page = provider.current;
    final isLastPage = provider.isLastPage;

    return Stack(
      children: [
        OnboardingBackground(image: page.image, pageKey: provider.currentPage),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 20.r),
                child: SvgPicture.asset(IconConstants.logoWhite, width: 200.r, height: 200.r),
              ),
              const Spacer(),
              OnboardingMobileSlide(
                pageKey: provider.currentPage,
                title: page.title,
                description: page.description,
              ),
              SizedBox(height: 32.r),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32.r, vertical: 24.r),
                child: Column(
                  children: [
                    OnboardingPageIndicator(count: provider.pageCount, currentIndex: provider.currentPage),
                    SizedBox(height: 24.r),
                    Row(
                      children: [
                        if (!provider.isFirstPage) OnboardingBackButton(onTap: provider.goBack),
                        if (!provider.isFirstPage) SizedBox(width: 12.r),
                        Expanded(child: OnboardingNextButton(isLastPage: isLastPage, onTap: onNext)),
                        if (!isLastPage) SizedBox(width: 12.r),
                        if (!isLastPage) OnboardingSkipButton(onTap: onSkip),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
