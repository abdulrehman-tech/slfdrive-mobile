import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../provider/language_selection_provider.dart';
import '../models/language_option.dart';
import 'branding_header.dart';
import 'continue_button.dart';
import 'language_list.dart';
import 'language_search_field.dart';

class LanguageMobileLayout extends StatelessWidget {
  final bool isTablet;
  final ValueChanged<LanguageOption> onLanguageSelected;
  final VoidCallback onContinue;

  const LanguageMobileLayout({
    super.key,
    required this.isTablet,
    required this.onLanguageSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageSelectionProvider>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.r : 24.r),
      child: Column(
        children: [
          SizedBox(height: 20.r),
          const BrandingHeader(),
          SizedBox(height: 24.r),
          LanguageSearchField(controller: provider.searchController),
          SizedBox(height: 20.r),
          Expanded(
            child: LanguageList(
              languages: provider.filteredLanguages,
              selectedCode: provider.selectedLanguageCode,
              onSelected: onLanguageSelected,
            ),
          ),
          SizedBox(height: 24.r),
          ContinueButton(
            enabled: provider.hasSelection,
            isLoading: provider.isApplying,
            onTap: onContinue,
          ),
          SizedBox(height: 32.r),
        ],
      ),
    );
  }
}
