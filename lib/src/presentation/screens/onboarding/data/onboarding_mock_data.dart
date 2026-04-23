import 'package:easy_localization/easy_localization.dart';

import '../../../../constants/image_constants.dart';
import '../models/onboarding_page.dart';

class OnboardingMockData {
  static List<OnboardingPage> getPages() => [
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
}
