import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../constants/icon_constants.dart';
import '../provider/onboarding_provider.dart';
import 'onboarding_back_button.dart';
import 'onboarding_next_button.dart';
import 'onboarding_page_indicator.dart';
import 'onboarding_skip_button.dart';

class OnboardingDesktopLayout extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingDesktopLayout({super.key, required this.onNext, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final page = provider.current;
    final isLastPage = provider.isLastPage;

    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: ClipRRect(
                    key: ValueKey(provider.currentPage),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.asset(page.image, fit: BoxFit.cover, height: double.infinity),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(IconConstants.logoWhite, width: 120, height: 120),
                      const SizedBox(height: 60),
                      OnboardingPageIndicator(
                        count: provider.pageCount,
                        currentIndex: provider.currentPage,
                        isDesktop: true,
                      ),
                      const SizedBox(height: 40),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          page.title,
                          key: ValueKey('title_${provider.currentPage}'),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          page.description,
                          key: ValueKey('desc_${provider.currentPage}'),
                          style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.9), height: 1.6),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (!provider.isFirstPage)
                            OnboardingBackButton(onTap: provider.goBack, isDesktop: true),
                          if (!provider.isFirstPage) const SizedBox(width: 16),
                          Expanded(
                            child: OnboardingNextButton(
                              isLastPage: isLastPage,
                              onTap: onNext,
                              isDesktop: true,
                            ),
                          ),
                          if (!isLastPage) const SizedBox(width: 16),
                          if (!isLastPage) OnboardingSkipButton(onTap: onSkip, isDesktop: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
