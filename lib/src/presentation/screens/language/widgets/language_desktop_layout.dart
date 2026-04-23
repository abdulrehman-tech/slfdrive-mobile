import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/language_selection_provider.dart';
import '../models/language_option.dart';
import 'branding_header.dart';
import 'continue_button.dart';
import 'language_list.dart';
import 'language_search_field.dart';

class LanguageDesktopLayout extends StatelessWidget {
  final ValueChanged<LanguageOption> onLanguageSelected;
  final VoidCallback onContinue;

  const LanguageDesktopLayout({
    super.key,
    required this.onLanguageSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageSelectionProvider>();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Row(
          children: [
            const Expanded(
              flex: 5,
              child: BrandingHeader(isDesktop: true),
            ),
            const SizedBox(width: 80),
            Expanded(
              flex: 5,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LanguageSearchField(
                      controller: provider.searchController,
                      isDesktop: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 400,
                      child: LanguageList(
                        languages: provider.filteredLanguages,
                        selectedCode: provider.selectedLanguageCode,
                        isDesktop: true,
                        onSelected: onLanguageSelected,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ContinueButton(
                      enabled: provider.hasSelection,
                      isLoading: provider.isApplying,
                      isDesktop: true,
                      onTap: onContinue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
