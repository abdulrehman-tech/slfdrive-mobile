import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/storage_keys.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  bool get isEnglish => _locale.languageCode == 'en';
  bool get isArabic => _locale.languageCode == 'ar';

  String get fontFamily => isArabic ? 'Tajawal' : 'OpenSans';

  TextDirection get textDirection {
    if (_locale.languageCode == 'ar' || _locale.languageCode == 'ur') {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(StorageKeys.languageCode);

      if (languageCode != null) {
        _locale = Locale(languageCode, languageCode == 'ar' ? 'AE' : 'US');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.languageCode, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Future<void> toggleLanguage() async {
    if (isEnglish) {
      await setLocale(const Locale('ar', 'AE'));
    } else {
      await setLocale(const Locale('en', 'US'));
    }
  }
}
