import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../constants/breakpoints.dart';
import 'models/language_option.dart';
import 'provider/language_selection_provider.dart';
import 'widgets/language_desktop_layout.dart';
import 'widgets/language_mobile_layout.dart';
import 'widgets/theme_toggle_bar.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageSelectionProvider(),
      child: const _LanguageSelectionView(),
    );
  }
}

class _LanguageSelectionView extends StatelessWidget {
  const _LanguageSelectionView();

  Future<void> _onLanguageSelected(
    BuildContext context,
    LanguageOption language,
  ) async {
    final provider = context.read<LanguageSelectionProvider>();
    provider.selectLanguage(language);
    await context.setLocale(language.locale);
  }

  Future<void> _onContinue(BuildContext context) async {
    final provider = context.read<LanguageSelectionProvider>();
    if (!provider.hasSelection) return;

    provider.setApplying(true);
    if (!context.mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
            final isTablet = Breakpoints.isTablet(constraints.maxWidth);

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 48.0 : (isTablet ? 32.0 : 24.r),
                    vertical: isDesktop ? 24.0 : (isTablet ? 20.0 : 16.r),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [ThemeToggleBar()],
                  ),
                ),
                Expanded(
                  child: isDesktop
                      ? LanguageDesktopLayout(
                          onLanguageSelected: (lang) => _onLanguageSelected(context, lang),
                          onContinue: () => _onContinue(context),
                        )
                      : LanguageMobileLayout(
                          isTablet: isTablet,
                          onLanguageSelected: (lang) => _onLanguageSelected(context, lang),
                          onContinue: () => _onContinue(context),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
