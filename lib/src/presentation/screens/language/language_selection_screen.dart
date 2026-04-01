import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../constants/icon_constants.dart';
import '../../../constants/color_constants.dart';
import '../../providers/theme_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;
  final TextEditingController _searchController = TextEditingController();
  List<LanguageOption> _filteredLanguages = [];

  final List<LanguageOption> _allLanguages = [
    LanguageOption(code: 'en', name: 'English', flag: '🇺🇸', locale: const Locale('en', 'US')),
    LanguageOption(code: 'ar', name: 'العربية', flag: '🇴🇲', locale: const Locale('ar', 'AE')),
    LanguageOption(code: 'hi', name: 'हिन्दी', flag: '🇮🇳', locale: const Locale('hi', 'IN')),
    LanguageOption(code: 'ur', name: 'اردو', flag: '🇵🇰', locale: const Locale('ur', 'PK')),
    LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪', locale: const Locale('de', 'DE')),
    LanguageOption(code: 'es', name: 'Español', flag: '🇪🇸', locale: const Locale('es', 'ES')),
    LanguageOption(code: 'ru', name: 'Русский', flag: '🇷🇺', locale: const Locale('ru', 'RU')),
  ];

  @override
  void initState() {
    super.initState();
    _filteredLanguages = _allLanguages;
    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = _allLanguages;
      } else {
        _filteredLanguages = _allLanguages.where((lang) => lang.name.toLowerCase().contains(query)).toList();
      }
    });
  }

  void _onLanguageSelected(LanguageOption language) async {
    setState(() {
      _selectedLanguage = language.code;
    });

    await context.setLocale(language.locale);
  }

  void _onContinue() async {
    if (_selectedLanguage == null) return;

    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        _ThemeButton(
                          icon: Icons.light_mode,
                          isSelected: !isDark,
                          onTap: () => themeProvider.setLightMode(),
                        ),
                        _ThemeButton(
                          icon: Icons.dark_mode,
                          isSelected: isDark,
                          onTap: () => themeProvider.setDarkMode(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.r),
                child: Column(
                  children: [
                    SizedBox(height: 20.r),

                    SvgPicture.asset(isDark ? IconConstants.logoWhite : IconConstants.logo, width: 140.r, height: 80.r),

                    SizedBox(height: 32.r),

                    Text(
                      'choose_language'.tr(),
                      style: TextStyle(
                        fontSize: 24.r,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                      ),
                    ),

                    SizedBox(height: 8.r),

                    Text(
                      'choose_language_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.r,
                        color: isDark ? Colors.white70 : const Color(0xFF757575),
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 24.r),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'search'.tr(),
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                            fontSize: 16.r,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                            size: 24.r,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
                        ),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16.r),
                      ),
                    ),

                    SizedBox(height: 20.r),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 8.r),
                          itemCount: _filteredLanguages.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark ? Colors.grey[800] : const Color(0xFFF0F0F0),
                          ),
                          itemBuilder: (context, index) {
                            final language = _filteredLanguages[index];
                            final isSelected = _selectedLanguage == language.code;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _onLanguageSelected(language),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 16.r),
                                  decoration: BoxDecoration(
                                    color: isSelected ? secondaryColor.withOpacity(0.08) : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(language.flag, style: TextStyle(fontSize: 28.r)),

                                      SizedBox(width: 16.r),

                                      Expanded(
                                        child: Text(
                                          language.name,
                                          style: TextStyle(
                                            fontSize: 16.r,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                                          ),
                                        ),
                                      ),

                                      if (isSelected) Icon(Icons.check_circle, color: secondaryColor, size: 24.r),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 24.r),

                    Container(
                      width: double.infinity,
                      height: 56.r,
                      decoration: BoxDecoration(
                        gradient: _selectedLanguage != null
                            ? const LinearGradient(
                                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: _selectedLanguage == null ? (isDark ? Colors.grey[800] : const Color(0xFFE0E0E0)) : null,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _selectedLanguage != null ? _onContinue : null,
                          borderRadius: BorderRadius.circular(16.r),
                          child: Center(
                            child: Text(
                              'continue'.tr(),
                              style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.r),
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

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
          decoration: BoxDecoration(
            color: isSelected ? secondaryColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 20.r,
            color: isSelected ? secondaryColor : (isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  final Locale locale;

  LanguageOption({required this.code, required this.name, required this.flag, required this.locale});
}
